class ChangeContestWinnersFromFinalizedToFinalizedAt < ActiveRecord::Migration
  def up
    rename_column :contest_winners, :finalized, :finalized_at
  end

  def down
    rename_column :contest_winners, :finalized_at, :finalized
  end
end
