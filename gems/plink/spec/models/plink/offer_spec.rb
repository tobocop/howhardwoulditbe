require 'spec_helper'

describe Plink::Offer do

  context 'when the offers info is not overridden by associated objects' do
    let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

    before do
      @plink_offer = create_offer(
          detail_text: 'one text',
          advertiser_id: advertiser.id,
          offers_virtual_currencies: [
              new_offers_virtual_currency(
                  virtual_currency_id: 3,
                  tiers: [
                      new_tier(
                          dollar_award_amount: 0.52,
                          minimum_purchase_amount: 1.00
                      ),
                      new_tier(
                          dollar_award_amount: 1.43,
                          minimum_purchase_amount: 2.00
                      ),
                      new_tier(
                          dollar_award_amount: 0.23,
                          minimum_purchase_amount: 0.50
                      )
                  ]
              ),
              new_offers_virtual_currency(
                  virtual_currency_id: 4,
                  tiers: [
                      new_tier(
                          dollar_award_amount: 2.50,
                          minimum_purchase_amount: 1.15
                      )
                  ]
              )
          ]
      )

    end

    subject { Plink::Offer.new(@plink_offer, 3) }

    it 'uses info from an offer record to populate all fields' do
      subject.tiers.count.should == 3
      subject.tiers.map(&:class).should == [Plink::Tier, Plink::Tier, Plink::Tier]
      subject.detail_text.should == 'one text'
      subject.name.should == 'cold wavy'
      subject.image_url.should == 'fake.jpg'
      subject.id.should == @plink_offer.id
      subject.max_dollar_award_amount.should == 1.43
    end

    describe '#tiers_by_minimum_purchase_amount' do
      it 'returns tiers sorted by their minimum purchase amount ascending' do
        subject.tiers_by_minimum_purchase_amount.map(&:minimum_purchase_amount).should == [0.50, 1.00, 2.00]
      end
    end

    describe '#minimum_purchase_amount_tier' do
      it 'returns the tier with the lowest minimum purchase amount' do
        minimum_purchase_tier = subject.minimum_purchase_amount_tier
        minimum_purchase_tier.minimum_purchase_amount.should == 0.50
      end
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

    subject { Plink::Offer.new(offer, 3) }

    it 'takes an offer_record and structures it to be handed back' do
      subject.tiers.count.should == 2
      subject.detail_text.should == 'override text'
    end
  end

  context 'when an offer has no tiers' do
    let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

    before do
      @plink_offer = create_offer(
          detail_text: 'one text',
          advertiser_id: advertiser.id,
          offers_virtual_currencies: [
              new_offers_virtual_currency(
                  virtual_currency_id: 3

              )
          ]
      )
    end

    subject { Plink::Offer.new(@plink_offer, 3) }

    it 'does not blow up when you ask for tier related data' do
      subject.tiers.should == []
      subject.max_dollar_award_amount.should == nil
      subject.tiers_by_minimum_purchase_amount.should == []
      subject.minimum_purchase_amount_tier.should == nil
    end
  end
end