class CreateContestWinners < ActiveRecord::Migration
  def up
    create_table :contest_winners do |t|
      t.integer :contest_id
      t.integer :user_id
      t.integer :prize_level_id
      t.integer :admin_user_id
      t.boolean :winner
      t.boolean :rejected
      t.timestamp :finalized

      t.timestamps
    end
  end

  def down
    drop_table :contest_winners
  end
end
