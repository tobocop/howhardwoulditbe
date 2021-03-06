namespace :contest do
  desc 'Reminder email for contest entrants who entered yesterday but not today'
  task daily_reminder_email: :environment do
    begin
      puts "[#{Time.zone.now}] Beginning daily reminder email:"; stars

      users_to_email = users_with_contest_reminders_who_have_not_entered_recently(1.day.ago.to_date)
      contest_email = Plink::ContestRecord.current.contest_emails

      users_to_email.each do |user|
        send_daily_reminder_email(user, contest_email)
      end

      stars ; puts "[#{Time.zone.now}] End of daily reminder email."
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "daily_reminder_email Rake task failed")
    end
  end

  desc 'Reminder email for contest entrants who entered three days ago, but not since'
  task three_day_reminder_email: :environment do
    begin
      puts "[#{Time.zone.now}] Beginning daily reminder email:"; stars

      users_to_email = users_with_contest_reminders_who_have_not_entered_recently(3.days.ago.to_date)
      contest_email = Plink::ContestRecord.current.contest_emails

      users_to_email.each do |user|
        send_three_day_reminder_email(user, contest_email)
      end

      stars; puts "[#{Time.zone.now}] End of three day reminder email."
    rescue Exception => e
      ::Exceptional::Catcher.handle($!, "three_day_reminder_email Rake task failed")
    end
  end

  desc 'Create contest prize levels for a given contest_id'
  task :create_prize_levels_for_contest, [:contest_id] => :environment do |t, args|
    contest_id = args[:contest_id]
    raise ArgumentError.new('contest_id is required') unless contest_id.present?

    if contest_id == 1 || contest_id == '1'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 250, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 100, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 50, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 20, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 10, award_count: 16)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 60)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 50)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 20)
    end

    if contest_id == 2 || contest_id == '2'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 350, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 100, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 50, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 25, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 20)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 50)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 76)
    end

    if contest_id == 3 || contest_id == '3'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 500, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 100, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 25, award_count: 5)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 23)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 40)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 80)
    end

    if contest_id == 4 || contest_id == '4'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 440, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 100, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 50, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 5)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 42)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 100)
    end

    if contest_id == 5 || contest_id == '5'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 400, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 100, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 25, award_count: 7)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 10, award_count: 10)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 12)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 45)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 74)
    end

    if contest_id == 6 || contest_id == '6'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 500, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 25, award_count: 7)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 10, award_count: 10)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 12)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 45)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 75)
    end

    if contest_id == 7 || contest_id == '7'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 635, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 25, award_count: 4)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 10, award_count: 6)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 8)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 34)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 97)
    end

    if contest_id == 8 || contest_id == '8'
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 500, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 25, award_count: 7)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 10, award_count: 10)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 5, award_count: 12)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 2, award_count: 45)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest_id, dollar_amount: 1, award_count: 75)
    end
  end

  desc 'Choose contest winners for a given contest_id'
  task :select_winners_for_contest, [:contest_id] => :environment do |t, args|
    contest_id = args[:contest_id]
    raise ArgumentError.new('contest_id is required') unless contest_id.present?

    PlinkAdmin::SelectContestWinnersService.process!(contest_id)
  end

  desc 'Post on Contest Winner\'s Facebook wall on their behalf'
  task :post_on_winners_behalf, [:contest_id, :automated_post] => :environment do |t, args|
    contest_id = args[:contest_id]
    raise ArgumentError.new('contest_id is required') unless contest_id.present?

    automated_post = args[:automated_post]
    raise ArgumentError.new('automated_post is required') unless automated_post.present?

    PlinkAdmin::NotifyContestWinnersService.notify!(contest_id, automated_post)
  end

private

  def send_daily_reminder_email(user, contest_email)
    begin
      reminder_args = {
        contest_email: contest_email,
        email: user.email,
        first_name: user.first_name,
        user_id: user.id
      }

      ContestMailer.daily_reminder_email(reminder_args).deliver
      puts "[#{Time.zone.now}] ID: #{user.id} EMAIL: #{user.email} FIRST NAME: #{user.first_name}"
    rescue Exception
      ::Exceptional::Catcher.handle($!, "daily_reminder_email failure for user.id = #{user.id}")
    end
  end

  def send_three_day_reminder_email(user, contest_email)
    begin
      reminder_args = {
        contest_email: contest_email,
        email: user.email,
        first_name: user.first_name,
        user_id: user.id
      }

      ContestMailer.three_day_reminder_email(reminder_args).deliver
      puts "[#{Time.zone.now}] Sent 3 day reminder email to ID: #{user.id} EMAIL: #{user.email} FIRST NAME: #{user.first_name}"
    rescue Exception
      ::Exceptional::Catcher.handle($!, "three_day_reminder_email failure for user.id = #{user.id}")
    end
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
