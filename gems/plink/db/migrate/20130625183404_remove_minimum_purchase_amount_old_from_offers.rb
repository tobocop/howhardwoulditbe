class RemoveMinimumPurchaseAmountOldFromOffers < ActiveRecord::Migration
  def up
    remove_column :offers, :minimumPurchaseAmount_old
  end

  def down
    add_column :offers, :minimumPurchaseAmount_old, :string, limit: 250
  end
end
