module Plink
  class WalletItemUnlockingService

    def self.unlock_transaction_items_for_eligible_users
      Plink::WalletRecord.wallets_eligible_for_transaction_unlocks.each do |wallet_record|
        self.unlock(wallet_record, Plink::WalletRecord.transaction_unlock_reason)
      end
    end

    def self.unlock_promotional_items_for_eligible_users
      Plink::WalletRecord.wallets_eligible_for_promotional_unlocks.each do |wallet_record|
        wallet_item_params = {
          wallet_id: wallet_record.id,
          wallet_slot_id: 1,
          wallet_slot_type_id: 1,
          unlock_reason: Plink::WalletRecord.promotion_unlock_reason
        }
        Plink::OpenWalletItemRecord.create(wallet_item_params)
      end
    end

    def self.unlock_wallet_item_record(wallet_item_record, reason)
      wallet_item_record.unlock_reason = reason
      wallet_item_record.type = 'Plink::OpenWalletItemRecord'
      wallet_item_record.save
    end

  private

    def self.unlock(wallet_record, reason)
      return if wallet_record.locked_wallet_items.empty?

      wallet_item = wallet_record.locked_wallet_items.first
      wallet_item.unlock_reason = reason
      wallet_item.type = 'Plink::OpenWalletItemRecord'
      wallet_item.save!
    end

  end
end
