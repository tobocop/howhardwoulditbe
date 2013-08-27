module Plink
  class WalletRecord < ActiveRecord::Base
    self.table_name = 'wallets'

    include Plink::LegacyTimestamps

    UNLOCK_REASONS = {
      transaction: 'transaction',
      join: 'join',
      referral: 'referral'
    }

    alias_attribute :user_id, :userID

    attr_accessible :user_id

    has_many :wallet_item_records, class_name: 'Plink::WalletItemRecord', foreign_key: 'walletID'
    has_many :sorted_wallet_item_records, class_name: 'Plink::WalletItemRecord',
             foreign_key: 'walletID', order: 'offersVirtualCurrencyID DESC, unlock_reason DESC'
    has_many :open_wallet_items, class_name: 'Plink::OpenWalletItemRecord', foreign_key: 'walletID'
    has_many :locked_wallet_items, class_name: 'Plink::LockedWalletItemRecord', foreign_key: 'walletID'
    belongs_to :user, class_name: 'Plink::UserRecord', foreign_key: 'userID'

    validates :user_id, presence: true

    scope :wallets_with_locked_wallet_items, -> {
      joins(:locked_wallet_items)
    }

    scope :wallets_of_users_with_qualifying_transactions, -> {
      where('userID IN (?)', Plink::UserRecord.user_ids_with_qualifying_transactions)
    }

    scope :wallets_without_unlocked_transaction_wallet_items, -> {
      joins("LEFT JOIN #{Plink::WalletItemRecord.table_name}
        ON #{Plink::WalletRecord.table_name}.walletID = #{Plink::WalletItemRecord.table_name}.walletID
        AND #{Plink::WalletItemRecord.table_name}.unlock_reason = '#{transaction_unlock_reason}'")
      .where("#{Plink::WalletItemRecord.table_name}.unlock_reason IS NULL")
    }

    scope :wallets_eligible_for_transaction_unlocks, -> {
      joins(Plink::WalletRecord.table_name)
      .where(%Q{EXISTS (
        SELECT 1
        FROM #{Plink::QualifyingAwardRecord.table_name}
        WHERE #{Plink::QualifyingAwardRecord.table_name}.userID = #{Plink::WalletRecord.table_name}.userID
        )}
      )
      .where(%Q{NOT EXISTS (
        SELECT 1
        FROM #{Plink::WalletItemRecord.table_name}
        WHERE #{Plink::WalletItemRecord.table_name}.unlock_reason = '#{self.transaction_unlock_reason}'
          AND #{Plink::WalletRecord.table_name}.walletID = #{Plink::WalletItemRecord.table_name}.walletID
        )}
      )
    }

    def self.transaction_unlock_reason
      UNLOCK_REASONS[:transaction]
    end

    def self.join_unlock_reason
      UNLOCK_REASONS[:join]
    end

    def self.referral_unlock_reason
      UNLOCK_REASONS[:referral]
    end
  end
end
