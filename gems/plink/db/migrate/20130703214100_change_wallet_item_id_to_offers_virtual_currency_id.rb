class ChangeWalletItemIdToOffersVirtualCurrencyId < ActiveRecord::Migration
  def change
    remove_index :usersAwardPeriods, :wallet_item_id
    rename_column :usersAwardPeriods, :wallet_item_id, :offers_virtual_currency_id
    add_index :usersAwardPeriods, :offers_virtual_currency_id
  end
end
