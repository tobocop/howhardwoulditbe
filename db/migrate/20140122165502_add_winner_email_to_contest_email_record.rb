class AddWinnerEmailToContestEmailRecord < ActiveRecord::Migration
  def change
    add_column :contest_emails, :winner_subject, :string
    add_column :contest_emails, :winner_preview, :string
    add_column :contest_emails, :winner_body, :text
    add_column :contest_emails, :winner_link_text, :string
    add_column :contest_emails, :winner_image, :string, limit: 100
  end
end
