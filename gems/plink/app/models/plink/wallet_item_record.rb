module Plink
  class WalletItemRecord < ActiveRecord::Base

    self.table_name = 'walletItems'

    include Plink::LegacyTimestamps

    alias_attribute :wallet_id, :walletID
    alias_attribute :wallet_slot_id, :walletSlotID
    alias_attribute :wallet_slot_type_id, :walletSlotTypeID
    alias_attribute :offers_virtual_currency_id, :offersVirtualCurrencyID

    attr_accessible :wallet_id, :wallet_slot_id, :wallet_slot_type_id, :offers_virtual_currency_id

    validates :wallet_id, :wallet_slot_id, :wallet_slot_type_id, presence: true

    belongs_to :offers_virtual_currency, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offersVirtualCurrencyID'
    has_one :offer, through: :offers_virtual_currency

    scope :empty, -> { where(offersVirtualCurrencyID: nil) }

    def assign_offer(offers_virtual_currency)
      self.offers_virtual_currency_id = offers_virtual_currency.id
      self.save
    end

    def unassign_offer
      self.offers_virtual_currency_id = nil
      self.save
    end
  end
end