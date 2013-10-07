class CreateUserAutoLogins < ActiveRecord::Migration
  def up
    create_table :user_auto_logins do |t|
      t.integer :user_id
      t.datetime :expires_at
      t.string :user_token, limit: 60

      t.timestamps
    end
  end

  def down
    drop_table :user_auto_logins
  end
end
