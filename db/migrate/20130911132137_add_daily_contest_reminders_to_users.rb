class AddDailyContestRemindersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :daily_contest_reminder, :boolean
  end
end
