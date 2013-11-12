class ChangeLengthOnWalletItemsUnlockReason < ActiveRecord::Migration
  def up
    change_table :walletItems do |t|
      t.change :unlock_reason, :string, :limit => 50
    end
  end

  def down
    change_table :walletItems do |t|
      t.change :unlock_reason, :string, :limit => 15
    end
  end
end
