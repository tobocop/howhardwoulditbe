class ChangeContestsPrizeToTextField < ActiveRecord::Migration
  def up
    change_column :contests, :prize, :text
  end

  def down
    change_column :contests, :prize, :string
  end
end
