module Plink
  class OfferService
    def get_offers(virtual_currency_id)
      Offer.all
    end
  end
end
