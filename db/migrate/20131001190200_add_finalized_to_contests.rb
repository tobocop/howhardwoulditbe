class AddFinalizedToContests < ActiveRecord::Migration
  def change
    add_column :contests, :finalized_at, :datetime
  end
end
