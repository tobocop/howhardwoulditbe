require 'spec_helper'

describe Plink::Offer do

  context 'when the offers info is not overridden by associated objects' do
    let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

    let(:plink_offer) {
      create_offer(
          detail_text: 'one text',
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

    subject { Plink::Offer.new(plink_offer) }

    it 'uses info from an offer record to populate all fields' do
      subject.tiers.count.should == 2
      subject.tiers.map(&:class).should == [Plink::Tier, Plink::Tier]
      subject.detail_text.should == 'one text'
      subject.name.should == 'cold wavy'
      subject.image_url.should == 'fake.jpg'
      subject.id.should == plink_offer.id
      subject.max_dollar_award_amount.should == 1.43
    end
  end

  context 'when the offers virtual currency overrides some values' do
    let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

    let(:offer) {
      create_offer(
          detail_text: 'one text',
          advertiser_id: advertiser.id,
          offers_virtual_currencies: [
              new_offers_virtual_currency(
                  virtual_currency_id: 3,
                  detail_text: 'override text',
                  tiers: [
                      new_tier(
                          dollar_award_amount: 1.43
                      ),
                      new_tier(
                          dollar_award_amount: 0.52
                      )
                  ]
              )
          ]
      )
    }

    subject { Plink::Offer.new(offer) }

    it 'takes an offer_record and structures it to be handed back' do
      subject.tiers.count.should == 2
      subject.detail_text.should == 'override text'
    end
  end
end