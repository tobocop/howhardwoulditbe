class AddTypeColumnToWalletItems < ActiveRecord::Migration
  def change
    add_column :walletItems, :type, :string
  end
end
