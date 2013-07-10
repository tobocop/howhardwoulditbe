module Plink
  class WalletItemRecord < ActiveRecord::Base

    self.table_name = 'walletItems'

    include Plink::LegacyTimestamps

    alias_attribute :wallet_id, :walletID
    alias_attribute :wallet_slot_id, :walletSlotID
    alias_attribute :wallet_slot_type_id, :walletSlotTypeID
    alias_attribute :users_award_period_id, :usersAwardPeriodID
    alias_attribute :offers_virtual_currency_id, :offersVirtualCurrencyID

    attr_accessible :wallet_id, :wallet_slot_id, :wallet_slot_type_id, :offers_virtual_currency_id

    validates :wallet_id, :wallet_slot_id, :wallet_slot_type_id, presence: true

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