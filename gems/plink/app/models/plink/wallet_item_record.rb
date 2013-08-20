module Plink
  class WalletItemRecord < ActiveRecord::Base

    self.table_name = 'walletItems'

    include Plink::LegacyTimestamps

    alias_attribute :wallet_id, :walletID
    alias_attribute :wallet_slot_id, :walletSlotID
    alias_attribute :wallet_slot_type_id, :walletSlotTypeID
    alias_attribute :users_award_period_id, :usersAwardPeriodID
    alias_attribute :offers_virtual_currency_id, :offersVirtualCurrencyID

    attr_accessible :wallet_id, :wallet_slot_id, :wallet_slot_type_id, :offers_virtual_currency_id, :unlock_reason, :users_award_period_id

    validates :wallet_id, :wallet_slot_id, :wallet_slot_type_id, presence: true
    validates_uniqueness_of :offersVirtualCurrencyID, scope: :walletID, unless: -> { offersVirtualCurrencyID.nil? }
    validates :unlock_reason, inclusion: {in: Plink::WalletRecord::UNLOCK_REASONS.values},
      allow_nil: true, allow_blank: false

    scope :wallets_with_an_unlock_reason_of_transaction, -> {
      select(:walletID)
      .where('unlock_reason = ?', Plink::WalletRecord::UNLOCK_REASONS[:transaction])
    }

    scope :wallets_with_an_unlock_reason_of_join, -> {
      select(:walletID)
      .where('unlock_reason = ?', Plink::WalletRecord::UNLOCK_REASONS[:join])
    }

    scope :wallets_with_an_unlock_reason_of_referral, -> {
      select(:walletID)
      .where('unlock_reason = ?', Plink::WalletRecord::UNLOCK_REASONS[:referral])
    }

    scope :locked, -> { where(type: Plink::LockedWalletItemRecord) }
    scope :open_records, -> { where(type: Plink::OpenWalletItemRecord) }
    scope :populated_records, -> { where(type: Plink::PopulatedWalletItemRecord) }

    scope :legacy_wallet_items_requiring_conversion, -> {
      select(%Q{
        #{self.table_name}.*,
        #{Plink::QualifyingAwardRecord.table_name}.isSuccessful AS has_qualifying_transaction,
        CASE
          WHEN #{Plink::ReferralConversionRecord.table_name}.referredBy IS NULL THEN 0
          ELSE 1
        END AS has_referral
      })
      .joins("INNER JOIN #{Plink::WalletRecord.table_name} ON #{self.table_name}.walletID = #{Plink::WalletRecord.table_name}.walletID")
      .joins("LEFT OUTER JOIN #{Plink::QualifyingAwardRecord.table_name} ON #{Plink::WalletRecord.table_name}.userID = #{Plink::QualifyingAwardRecord.table_name}.userID")
      .joins("LEFT OUTER JOIN #{Plink::ReferralConversionRecord.table_name} ON #{Plink::ReferralConversionRecord.table_name}.referredBy = #{Plink::WalletRecord.table_name}.userID")
      .where("#{self.table_name}.type != 'Plink::LockedWalletItemRecord'")
    }

    def convert_to(klass_name)
      self.type = klass_name
    end

    def locked?
      false
    end

    def populated?
      false
    end

    def open?
      false
    end

  end
end
