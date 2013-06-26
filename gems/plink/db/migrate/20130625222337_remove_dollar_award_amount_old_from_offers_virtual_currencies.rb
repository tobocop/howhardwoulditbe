class RemoveDollarAwardAmountOldFromOffersVirtualCurrencies < ActiveRecord::Migration
  def up
    remove_column :offersVirtualCurrencies, :dollarAwardAmount_old
  end

  def down
    add_column :offersVirtualCurrencies, :dollarAwardAmount_old, :decimal, :precision => 12, :scale => 6
  end
end
