require 'spec_helper'

describe Plink::OfferService do
  describe 'get_offers' do
    it 'returns offers by virtual_currency_id' do

      # offer - start and end date, isActive, showOnWall
      # offersVirtualCurrencies - isActive, detail text override
      # tiers - start and end date, isActive

      advertiser = create_advertiser(advertiser_name: 'New Nervy')

      plink_offer = create_offer(
          advertiser_id: advertiser.id,
          offers_virtual_currencies: [
              new_offers_virtual_currency(
                  virtual_currency_id: 3,
                  tiers: [
                      new_tier(
                          dollar_award_amount: 1.43
                      )
                  ]
              )
          ]
      )

      swag_offer = create_offer(
        offers_virtual_currencies: [
            new_offers_virtual_currency(virtual_currency_id: 24)
        ]
      )

      offers = Plink::OfferService.new.get_offers(3)

      offers.map(&:id).should == [plink_offer.id]
      offers.map(&:class).should == [Plink::Offer]
    end
  end
end
