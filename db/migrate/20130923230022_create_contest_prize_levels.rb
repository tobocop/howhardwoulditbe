class CreateContestPrizeLevels < ActiveRecord::Migration
  def up
    create_table :contest_prize_levels do |t|
      t.integer :contest_id
      t.integer :award_count
      t.integer :dollar_amount

      t.timestamps
    end
  end

  def down
    drop_table :contest_prize_levels
  end
end
