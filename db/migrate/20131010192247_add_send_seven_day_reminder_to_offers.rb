class AddSendSevenDayReminderToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :send_seven_day_reminder, :boolean
  end
end
