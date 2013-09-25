module Plink
  class ContestWinningService

    def self.total_non_plink_entries_for_contest(contest_id)
      Plink::EntryRecord.joins('INNER JOIN users ON user_id = userID').
        where('emailAddress NOT LIKE ?', '%plink.com%').
        where(contest_id: contest_id).sum('computed_entries')
    end

    def self.cumulative_non_plink_entries_by_user(contest_id)
      Plink::EntryRecord.select("user_id, SUM(computed_entries) AS 'entries',
        (SELECT SUM(computed_entries) FROM entries e INNER JOIN users u ON e.user_id = u.userID AND u.emailAddress NOT LIKE '%plink.com%' WHERE e.user_id <= entries.user_id) AS 'cumulative_entries'").
        joins('INNER JOIN users ON userID = user_id').
        where(contest_id: contest_id).
        where('emailAddress NOT LIKE ?', '%plink.com%').
        group(:user_id, :userID).
        order('user_id ASC')
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
          Plink::ContestWinnerRecord.create!(user_id: user_id, contest_id: contest_id, prize_level_id: level.id, rejected: false, winner: false)
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
  end
end
