module Plink
  class WalletItemUnlockingService

    def self.unlock_transaction_items_for_eligible_users
      Plink::WalletRecord.wallets_eligible_for_transaction_unlocks.each do |wallet|
        self.unlock(wallet, Plink::WalletRecord::UNLOCK_REASONS[:transaction])
      end
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
