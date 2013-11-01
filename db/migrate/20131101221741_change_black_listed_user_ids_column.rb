class ChangeBlackListedUserIdsColumn < ActiveRecord::Migration
  def up
    remove_column :contest_blacklisted_user_ids, :email_pattern
    add_column :contest_blacklisted_user_ids, :user_id, :integer
  end

  def down
    add_column :contest_blacklisted_user_ids, :email_pattern, :string
    remove_column :contest_blacklisted_user_ids, :user_id
  end
end
