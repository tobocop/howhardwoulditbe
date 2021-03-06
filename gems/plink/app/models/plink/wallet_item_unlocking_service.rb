module Plink
  class WalletItemUnlockingService

    def self.unlock_transaction_items_for_eligible_users
      Plink::WalletRecord.wallets_eligible_for_transaction_unlocks.each do |wallet_record|
        self.unlock(wallet_record, Plink::WalletRecord.transaction_unlock_reason)
      end
    end

    def self.unlock_wallet_item_record(wallet_item_record, reason)
      wallet_item_record.unlock_reason = reason
      wallet_item_record.type = 'Plink::OpenWalletItemRecord'
      wallet_item_record.save
    end

    def self.unlock_referral_slot(user_id)
      wallet_record = Plink::UserRecord.find(user_id).wallet
      self.unlock(wallet_record, Plink::WalletRecord.referral_unlock_reason) unless wallet_record.unlocked_referral_slot?
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
