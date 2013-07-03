class AddWalletItemIdToUsersAwardPeriods < ActiveRecord::Migration
  def change
    add_column :usersAwardPeriods, :wallet_item_id, :integer, limit: 8
    add_index :usersAwardPeriods, :wallet_item_id
  end
end
