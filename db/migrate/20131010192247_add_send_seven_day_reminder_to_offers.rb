class AddSendSevenDayReminderToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :send_expiring_soon_reminder, :boolean
  end
end
