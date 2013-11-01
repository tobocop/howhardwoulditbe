class ChangeContestBlackListedEmails < ActiveRecord::Migration
  def up
    rename_table :contest_blacklisted_emails, :contest_blacklisted_user_ids
  end

  def down
    rename_table :contest_blacklisted_user_ids, :contest_blacklisted_emails
  end
end
