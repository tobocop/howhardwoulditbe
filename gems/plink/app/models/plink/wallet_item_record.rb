module Plink
  class WalletItemRecord < ActiveRecord::Base

    self.table_name = 'walletItems'

    include Plink::LegacyTimestamps

    alias_attribute :wallet_id, :walletID
    alias_attribute :wallet_slot_id, :walletSlotID
    alias_attribute :wallet_slot_type_id, :walletSlotTypeID
    alias_attribute :users_award_period_id, :usersAwardPeriodID
    alias_attribute :offers_virtual_currency_id, :offersVirtualCurrencyID

    attr_accessible :wallet_id, :wallet_slot_id, :wallet_slot_type_id, :offers_virtual_currency_id, :unlock_reason

    validates :wallet_id, :wallet_slot_id, :wallet_slot_type_id, presence: true
    validates_uniqueness_of :offersVirtualCurrencyID, scope: :walletID, unless: -> { offersVirtualCurrencyID.nil? }

    scope :wallets_with_an_unlock_reason_of_transaction, -> {
      select(:walletID)
      .where('unlock_reason = ?', Plink::WalletRecord::UNLOCK_REASONS[:transaction])
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