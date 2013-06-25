module Plink
  class FakeOfferService

    DEFAULT_OFFERS = {
        'www' => [
            'www_offer'
        ],
        'swagbucks' => [
            'swag_offer'
        ]
    }

    def initialize(offer_hash)
      @offers_hash = offer_hash || DEFAULT_OFFERS
    end

    def get_offers(subdomain)
      @offers_hash[subdomain]
    end
  end
end
