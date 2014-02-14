class CreateUsersSocialProfiles < ActiveRecord::Migration
  def up
    create_table :users_social_profiles do |t|
      t.integer :user_id
      t.text :profile

      t.timestamps
    end
  end

  def down
    drop_table :users_social_profiles
  end
end
