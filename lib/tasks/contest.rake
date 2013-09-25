namespace :contest do
  desc 'Reminder email for contest entrants who entered yesterday but not today'
  task daily_reminder_email: :environment do
    puts "[#{Time.zone.now}] Beginning daily reminder email:"; stars

    users_to_email = users_with_contest_reminders_who_have_not_entered_recently(1.day.ago.to_date)

    users_to_email.each do |user|
      reminder_args = {
        user_id: user.id,
        first_name: user.first_name,
        email: user.email
      }

      ContestMailer.daily_reminder_email(reminder_args).deliver
      puts "[#{Time.zone.now}] ID: #{user.id} EMAIL: #{user.email} FIRST NAME: #{user.first_name}"
    end

    stars ; puts "[#{Time.zone.now}] End of daily reminder email."
  end

  desc 'Reminder email for contest entrants who entered three days ago, but not since'
  task three_day_reminder_email: :environment do
    puts "[#{Time.zone.now}] Beginning daily reminder email:"; stars

    users_to_email = users_with_contest_reminders_who_have_not_entered_recently(3.days.ago.to_date)

    users_to_email.each do |user|
      reminder_args = {
        user_id: user.id,
        first_name: user.first_name,
        email: user.email
      }

      ContestMailer.three_day_reminder_email(reminder_args).deliver
      puts "[#{Time.zone.now}] Sent 3 day reminder email to ID: #{user.id} EMAIL: #{user.email} FIRST NAME: #{user.first_name}"
    end

    stars; puts "[#{Time.zone.now}] End of three day reminder email."
  end

  desc 'Create contest prize levels for a given contest_id'
  task :create_prize_levels_for_contest, [:contest_id] => :environment do |t, args|
    contest_id = args[:contest_id]
    raise ArgumentError.new('contest_id is required') unless contest_id.present?

    if contest_id == 1
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 250, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 100, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 50, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 20, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 10, award_count: 16)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 60)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 50)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 20)
    end
  end

  desc 'Choose contest winners for a given contest_id'
  task :select_winners_for_contest, [:contest_id] => :environment do |t, args|
    contest_id = args[:contest_id]
    raise ArgumentError.new('contest_id is required') unless contest_id.present?

    cumulative_entries_by_user =
      Plink::ContestWinningService.cumulative_non_plink_entries_by_user(contest_id)
    raise Exception.new("ERROR: Less than 300 entrants present! Cannot pick winners.") if cumulative_entries_by_user.length < 300

    outcome_table = Plink::ContestWinningService.generate_outcome_table(cumulative_entries_by_user)

    total_entries =
      Plink::ContestWinningService.total_non_plink_entries_for_contest(contest_id)

    winners = Plink::ContestWinningService.choose_winners(total_entries, outcome_table)

    receiving_prize = winners.first(150)
    Plink::ContestWinningService.create_prize_winners!(contest_id, receiving_prize)

    alternates = winners.last(150)
    Plink::ContestWinningService.create_alternates!(contest_id, alternates)
  end
end

def users_with_contest_reminders_who_have_not_entered_recently(last_entered_date)
  user_attrs = [:userID, :firstName, :emailAddress]

  Plink::UserRecord.select(user_attrs)
    .joins('INNER JOIN entries ON entries.user_id = users.userID')
    .where("daily_contest_reminder = 1")
    .group(user_attrs)
    .having("MAX(entries.created_at) >= ?", last_entered_date)
    .having("MAX(entries.created_at) < ?", last_entered_date + 1.day)
end

def stars
  puts '*' * 150
end
