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
