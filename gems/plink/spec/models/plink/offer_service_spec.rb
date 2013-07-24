require 'spec_helper'

describe Plink::OfferService do
  let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

  let!(:plink_offer) {
    create_offer(
        detail_text: 'one text',
        advertiser_id: advertiser.id,
        is_new: true,
        offers_virtual_currencies: [
            new_offers_virtual_currency(
                virtual_currency_id: 3,
                is_promotion: true,
                tiers: [
                    new_tier(
                        dollar_award_amount: 0.52
                    ),
                    new_tier(
                        dollar_award_amount: 1.43
                    )
                ]
            )
        ]
    )
  }

  describe 'get_live_offers' do
    it 'returns offers by virtual_currency_id' do
      offers = Plink::OfferService.new.get_live_offers(3)

      offer = offers.first
      offer.id.should == plink_offer.id
      offer.name.should == 'cold wavy'
      offer.image_url.should == 'fake.jpg'
      offer.is_new.should be_true
      offer.is_promotion.should be_true

      offers.map(&:class).should == [Plink::Offer]
    end
  end

  describe 'get_available_offers_for' do
    let!(:other_plink_offer) {
      create_offer(
        id: 123,
        detail_text: 'another offer',
        advertiser_id: advertiser.id,
        offers_virtual_currencies: [
          new_offers_virtual_currency(
            virtual_currency_id: 3,
            tiers: [
              new_tier(
                dollar_award_amount: 0.52
              ),
              new_tier(
                dollar_award_amount: 1.43
              )
            ]
          )
        ]
      )
    }

    it 'returns offers for the given wallet' do
      Plink::OfferRecord.stub(:in_wallet).with(7).and_return([plink_offer])

      offers = Plink::OfferService.new.get_available_offers_for(7, 3)

      offers.map(&:id).should == [123]

      offers.map(&:class).should == [Plink::Offer]
    end
  end
end
