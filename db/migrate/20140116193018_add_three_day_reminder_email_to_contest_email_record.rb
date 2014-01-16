class AddThreeDayReminderEmailToContestEmailRecord < ActiveRecord::Migration
  def change
    add_column :contest_emails, :three_day_subject, :string
    add_column :contest_emails, :three_day_preview, :string
    add_column :contest_emails, :three_day_body, :text
    add_column :contest_emails, :three_day_link_text, :string
    add_column :contest_emails, :three_day_image, :string, limit: 100
  end
end
