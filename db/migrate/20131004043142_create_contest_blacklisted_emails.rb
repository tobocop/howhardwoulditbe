class CreateContestBlacklistedEmails < ActiveRecord::Migration
  def up
    create_table :contest_blacklisted_emails do |t|
      t.string :email_pattern

      t.timestamps
    end
  end

  def down
    drop_table :contest_blacklisted_emails
  end
end
