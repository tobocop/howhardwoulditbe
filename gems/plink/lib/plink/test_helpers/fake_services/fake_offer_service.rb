module Plink
  class FakeOfferService

    DEFAULT_OFFERS = {
        1 => [
            'www_offer'
        ],
        2 => [
            'swag_offer'
        ]
    }

    def initialize(offer_hash)
      @offers_hash = offer_hash || DEFAULT_OFFERS
    end

    def get_offers(virtual_currency_id)
      @offers_hash[virtual_currency_id]
    end
  end
end
