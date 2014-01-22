module Plink
  class WalletRecord < ActiveRecord::Base
    self.table_name = 'wallets'

    include Plink::LegacyTimestamps

    UNLOCK_REASONS = {
      app_install_promotion: 'app_install_promotion',
      join: 'join',
      promotion: 'promotion',
      referral: 'referral',
      transaction: 'transaction'
    }

    alias_attribute :user_id, :userID

    attr_accessible :user_id, :wallet_item_records

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

    scope :wallets_eligible_for_transaction_unlocks, -> {
      self.wallets_without_item_unlocked(self.transaction_unlock_reason)
      .where(%Q{
        EXISTS (
          SELECT 1
          FROM qualifyingAwards
          WHERE qualifyingAwards.userID = wallets.userID
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

    def self.current_promotion_unlock_reason
      UNLOCK_REASONS[:app_install_promotion]
    end

    def self.transaction_promotion_unlock_reason
      UNLOCK_REASONS[:promotion]
    end

    def self.app_install_promotion_unlock_reason
      UNLOCK_REASONS[:app_install_promotion]
    end

    def has_offers_virtual_currency(offers_virtual_currency_id)
      wallet_item_records.any? {|wallet_item_record| wallet_item_record.offers_virtual_currency_id == offers_virtual_currency_id}
    end

    def unlocked_referral_slot?
      wallet_item_records.map(&:unlock_reason).include?(self.class.referral_unlock_reason)
    end

  private

    def self.wallets_without_item_unlocked(unlock_reason)
      where(%Q{
        NOT EXISTS (
          SELECT 1
          FROM walletItems
          WHERE walletItems.unlock_reason = '#{unlock_reason}'
            AND wallets.walletID = walletItems.walletID
        )}
      )
    end
  end
end
