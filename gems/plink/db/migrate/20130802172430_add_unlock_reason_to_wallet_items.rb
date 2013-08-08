class AddUnlockReasonToWalletItems < ActiveRecord::Migration
  def change
    add_column :walletItems, :unlock_reason, :string, limit: 15
  end
end
