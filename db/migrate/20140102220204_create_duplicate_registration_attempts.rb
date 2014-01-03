class CreateDuplicateRegistrationAttempts < ActiveRecord::Migration
  def up
    create_table :duplicate_registration_attempts do |t|
      t.integer :user_id, limit: 8
      t.integer :existing_users_institution_id, limit: 8

      t.timestamps
    end
  end

  def down
    drop_table :duplicate_registration_attempts
  end
end
