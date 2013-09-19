class CreateContests < ActiveRecord::Migration
  def up
    create_table :contests do |t|
      t.string :description
      t.string :image, limit: 100
      t.string :prize, limit: 100
      t.datetime :start_time
      t.datetime :end_time
      t.string :terms_and_conditions
      t.string :entry_method

      t.timestamps
    end
  end

  def down
    drop_table :contests
  end
end
