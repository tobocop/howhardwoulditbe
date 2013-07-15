class DeviseCreatePlinkAdminAdmins < ActiveRecord::Migration
  def change
    create_table(:plink_admin_admins) do |t|
      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Lockable
      t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.timestamps
    end

    add_index :plink_admin_admins, :email,                :unique => true
    add_index :plink_admin_admins, :reset_password_token, :unique => true
    # add_index :plink_admin_admins, :confirmation_token,   :unique => true
    # add_index :plink_admin_admins, :unlock_token,         :unique => true
    # add_index :plink_admin_admins, :authentication_token, :unique => true
  end
end
