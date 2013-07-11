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

    def get_live_offers(virtual_currency_id)
      @offers_hash[virtual_currency_id]
    end

    def get_available_offers_for(wallet_id, virtual_currency_id)
      @offers_hash[virtual_currency_id]
    end
  end
end
