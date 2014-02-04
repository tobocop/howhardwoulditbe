class CreateContacts < ActiveRecord::Migration
  def up
    create_table :contacts do |t|
      t.integer :brand_id
      t.string :email
      t.string :first_name
      t.boolean :is_active, default: true
      t.string :last_name

      t.timestamps
    end
  end

  def down
    drop_table :contacts
  end
end
