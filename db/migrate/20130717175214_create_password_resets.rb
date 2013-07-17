class CreatePasswordResets < ActiveRecord::Migration
  def change
    create_table :password_resets do |t|
      t.integer :user_id
      t.string :token, null: false

      t.timestamps
    end

    add_index :password_resets, :token, unique: true
  end
end
