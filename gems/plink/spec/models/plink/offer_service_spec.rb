require 'spec_helper'

describe Plink::OfferService do
  let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

  let!(:plink_offer) {
    create_offer(
        detail_text: 'one text',
        advertiser_id: advertiser.id,
        is_new: true,
        show_end_date: true,
        offers_virtual_currencies: [
            new_offers_virtual_currency(
                virtual_currency_id: 2,
                promotion_description: 'the description',
                is_promotion: false,
                is_active: true,
                tiers: [new_tier]
            ),
            new_offers_virtual_currency(
                virtual_currency_id: 3,
                promotion_description: 'the description',
                is_promotion: true,
                is_active: true,
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

  describe '#get_live_offers' do
    it 'returns offers by virtual_currency_id' do
      offers = Plink::OfferService.new.get_live_offers(3)

      offer = offers.first
      offer.id.should == plink_offer.id
      offer.name.should == 'cold wavy'
      offer.promotion_description.should == 'the description'
      offer.image_url.should == 'fake.jpg'
      offer.is_new.should be_true
      offer.is_promotion.should be_true
      offer.show_end_date.should be_true

      offers.map(&:class).should == [Plink::Offer]
    end
  end

  describe '#get_available_offers_for' do
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

  describe '#get_by_id_and_virtual_currency_id' do
    let(:offer_service) { Plink::OfferService.new }

    it 'requires an offer_id and a virtual_currency_id' do
      offer = offer_service.get_by_id_and_virtual_currency_id(plink_offer.id, 2)
      offer.id.should == plink_offer.id
    end

    it 'returns one offer object' do
      offer = offer_service.get_by_id_and_virtual_currency_id(plink_offer.id, 2)
      offer.should be_a Plink::Offer
    end
  end
end
