module Plink
  class EmptyWalletItemRecord < WalletItemRecord

    def assign_offer(offers_virtual_currency, award_period)
      self.offers_virtual_currency_id = offers_virtual_currency.id
      self.users_award_period_id = award_period.id
      self.convert_to 'Plink::PopulatedWalletItemRecord'
      self.save
    end

    def open?
      true
    end
  end
end