module Plink
  class WalletRecord < ActiveRecord::Base
    self.table_name = 'wallets'

    include Plink::LegacyTimestamps

    UNLOCK_REASONS = {
      transaction: 'transaction',
      join: 'join'
    }

    alias_attribute :user_id, :userID

    attr_accessible :user_id

    has_many :wallet_item_records, class_name: 'Plink::WalletItemRecord', foreign_key: 'walletID'
    has_many :open_wallet_items, class_name: 'Plink::OpenWalletItemRecord', foreign_key: 'walletID'
    has_many :locked_wallet_items, class_name: 'Plink::LockedWalletItemRecord', foreign_key: 'walletID'

    validates :user_id, presence: true

    scope :wallets_with_locked_wallet_items, -> {
      joins(:locked_wallet_items)
    }

    scope :wallets_of_users_with_qualifying_transactions, -> {
      where('userID IN (?)', Plink::UserRecord.user_ids_with_qualifying_transactions)
    }

    scope :wallets_without_unlocked_transaction_wallet_items, -> {
      joins("LEFT JOIN walletItems ON wallets.walletID = walletItems.walletID AND walletItems.unlock_reason = 'transaction'")
      .where('walletItems.unlock_reason IS NULL')
    }

    scope :wallets_eligible_for_transaction_unlocks, -> {
      wallets_without_unlocked_transaction_wallet_items
      .wallets_of_users_with_qualifying_transactions
    }

  end
end
