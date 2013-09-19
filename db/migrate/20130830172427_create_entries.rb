class CreateEntries < ActiveRecord::Migration
  def up
    create_table :entries do |t|
      t.integer :contest_id
      t.integer :user_id

      t.timestamps
    end
  end

  def down
    drop_table :entries
  end
end
