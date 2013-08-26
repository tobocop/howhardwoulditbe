module Plink
  class WalletItemUnlockingService

    def self.unlock_transaction_items_for_eligible_users
      Plink::WalletRecord.wallets_eligible_for_transaction_unlocks.find_in_batches(batch_size: 500) do |wallet_batch|
        wallet_batch.each do |wallet|
          self.unlock(wallet, Plink::WalletRecord::UNLOCK_REASONS[:transaction])
        end
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
