class PlinkAdmin::ContestWinningService
  def self.total_non_plink_entries_for_contest(contest_id)
    query = Plink::EntryRecord.
      where(contest_id: contest_id)

    blacklisted_user_ids = Plink::ContestBlacklistedEmailRecord.select(:user_id).map(&:user_id)
    if blacklisted_user_ids.present?
      query = query.
        joins('LEFT JOIN contest_blacklisted_user_ids cbui ON entries.user_id = cbui.user_id').
        where('cbui.user_id IS NULL')
    end

    query.sum('computed_entries')
  end

  def self.cumulative_non_plink_entries_by_user(contest_id)
    query = Plink::EntryRecord.select("entries.user_id, SUM(computed_entries) AS 'entries',
      (SELECT SUM(computed_entries) FROM entries e
        LEFT JOIN contest_blacklisted_user_ids cbui ON e.user_id = cbui.user_id
        WHERE cbui.user_id IS NULL AND e.user_id <= entries.user_id) AS 'cumulative_entries'").
      where(contest_id: contest_id).
      group('entries.user_id').
      order('entries.user_id ASC')

    blacklisted_user_ids = Plink::ContestBlacklistedEmailRecord.select(:user_id).map(&:user_id)
    if blacklisted_user_ids.present?
      query = query.
        joins('LEFT JOIN contest_blacklisted_user_ids cbui ON entries.user_id = cbui.user_id').
        where('cbui.user_id IS NULL')
    end

    query
  end

  def self.generate_outcome_table(cumulative_entries_by_user)
    raise ArgumentError.new('Need to provide cumulative entries by user') if cumulative_entries_by_user.blank?

    outcome_table = {}
    index = 1

    cumulative_entries_by_user.each do |user|
      user.entries.times do
        outcome_table[index] = user.user_id
        index += 1
      end
    end

    outcome_table
  end

  def self.choose_winners(total_entries, outcome_table)
    winners = []
    until winners.length >= 300 do
      winning_number = rand(total_entries) + 1
      winning_user_id = outcome_table[winning_number]
      winners << winning_user_id unless winners.include?(winning_user_id)
    end

    winners
  end

  def self.create_prize_winners!(contest_id, winners)
    raise ArgumentError.new('Must provide a contest_id') if contest_id.blank?
    raise ArgumentError.new('Must provide exactly 150 user_ids') if winners.length != 150

    prize_levels = Plink::ContestPrizeLevelRecord.where(contest_id: contest_id).order('dollar_amount DESC')
    prize_levels.each do |level|
      level.award_count.times do
        user_id = winners.shift
        Plink::ContestWinnerRecord.create!(user_id: user_id, contest_id: contest_id, prize_level_id: level.id, rejected: false, winner: true)
      end
    end
  end

  def self.create_alternates!(contest_id, alternates)
    raise ArgumentError.new('Must provide a contest_id') if contest_id.blank?
    raise ArgumentError.new('Must provide exactly 150 user_ids') if alternates.length != 150

    alternates.each do |user_id|
      Plink::ContestWinnerRecord.create!(user_id: user_id, contest_id: contest_id, prize_level_id: nil, rejected: false, winner: false)
    end
  end

  def self.remove_winning_record_and_update_prizes(contest_id, contest_winner_record_id, admin_id)
    raise ArgumentError.new('contest_id is required') if contest_id.blank?
    raise ArgumentError.new('contest_winner_record_id is required') if contest_winner_record_id.blank?

    prize_level_id = remove_winner(contest_winner_record_id, admin_id)

    winners_and_first_alternate = winners_and_first_alternate(contest_id, prize_level_id)

    update_prize_levels!(winners_and_first_alternate, prize_level_id)
  end

  def self.finalize_results!(contest_id, user_ids, admin_user_id)
    if user_ids.length != 150
      raise ArgumentError.new('Not enough users to finalize contest results.')
    end

    Plink::ContestWinnerRecord.where('contest_id = ? AND user_id IN (?)',  contest_id, user_ids).
      update_all({
        finalized_at: Time.zone.now,
        winner: true,
        rejected: false,
        admin_user_id: admin_user_id
      })

    Plink::ContestWinnerRecord.where(contest_id: contest_id).where(finalized_at: nil).
      where('prize_level_id IS NULL').update_all({
        finalized_at: Time.zone.now,
        winner: false,
        rejected: true,
        admin_user_id: admin_user_id
      })

    Plink::ContestRecord.find(contest_id).update_attributes(finalized_at: Time.zone.now)
  end

  def self.notify_winners!(contest_id)
    winners = Plink::ContestWinnerRecord.includes(:user).includes(:prize_level).
      joins('INNER JOIN users ON users.userID = contest_winners.user_id').
      where(contest_id: contest_id).
      where('finalized_at IS NOT NULL').where('prize_level_id IS NOT NULL').
      where(winner: true, rejected: false)

    winners.each do |winner|
      user_token = Plink::UserAutoLoginRecord.create(user_id: winner.user.id, expires_at: 2.days.from_now).user_token

      email_args = {
        email: winner.user.email,
        first_name: winner.user.first_name,
        contest_id: contest_id,
        user_id: winner.user.id,
        user_token: user_token
      }
      ContestMailer.delay.winner_email(email_args)
    end
  end

  def self.refresh_blacklisted_user_ids!
    Plink::ContestBlacklistedEmailRecord.delete_all

    results = PlinkAdmin::ContestQueryService.blacklisted_user_ids

    results.map {|result| result['user_id'].to_i }.each do |user_id|
      Plink::ContestBlacklistedEmailRecord.create!(user_id: user_id)
    end
  end

private

  def self.remove_winner(contest_winner_record_id, admin_id)
    to_be_removed = Plink::ContestWinnerRecord.find(contest_winner_record_id)
    prize_level_id = to_be_removed.prize_level_id

    to_be_removed.update_attributes({
      admin_user_id: admin_id,
      rejected: true,
      winner: false,
      finalized_at: Time.zone.now,
      prize_level_id: nil
    })

    prize_level_id
  end

  def self.winners_and_first_alternate(contest_id, prize_level_id)
    winners = Plink::ContestWinnerRecord.
      where(contest_id: contest_id).
      where('prize_level_id >= ?', prize_level_id).
      order('id ASC')

    first_alternate = Plink::ContestWinnerRecord.
      where(contest_id: contest_id).
      where('prize_level_id IS NULL').
      where('finalized_at IS NULL').
      where(rejected: false).
      order('id ASC').
      first

    winners << first_alternate
  end

  def self.update_prize_levels!(winners, prize_level_id)
    prize_levels = Plink::ContestPrizeLevelRecord.where('id >= ?', prize_level_id).order('id ASC')
    prize_levels.each do |prize_level|
      prize_level.award_count.times do
        winner = winners.shift
        winner.update_attributes(prize_level_id: prize_level.id)
      end
    end
  end
end
