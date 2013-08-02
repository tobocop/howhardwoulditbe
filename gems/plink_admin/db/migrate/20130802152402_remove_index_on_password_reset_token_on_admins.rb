class RemoveIndexOnPasswordResetTokenOnAdmins < ActiveRecord::Migration
  def up
    remove_index :plink_admin_admins, :reset_password_token
  end

  def down
    add_index :plink_admin_admins, :reset_password_token, :unique => true
  end
end
