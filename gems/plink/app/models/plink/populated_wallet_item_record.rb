module Plink
  class PopulatedWalletItemRecord < WalletItemRecord

    belongs_to :offers_virtual_currency, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offersVirtualCurrencyID'
    has_one :offer, through: :offers_virtual_currency

    def unassign_offer
      self.offers_virtual_currency_id = nil
      self.users_award_period_id = nil
      self.convert_to 'Plink::OpenWalletItemRecord'
      self.save
    end

    def populated?
      true
    end
  end
end