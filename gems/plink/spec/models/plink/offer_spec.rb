require 'spec_helper'

describe Plink::Offer do

  context 'when the offers info is not overridden by associated objects' do
    let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

    before do
      @plink_offer = create_offer(
        detail_text: 'one text',
        is_new: true,
        end_date: 1.day.ago.to_date,
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

    subject do
      Plink::Offer.new(
        {
          offer_record: @plink_offer,
          virtual_currency_id: 3,
          name: 'cold wavy',
          image_url: 'fake.jpg',
          is_new: true,
          promotion_description: 'good offer'
        }
      )
    end

    it 'uses info from an offer record to populate all fields' do
      subject.tiers.count.should == 3
      subject.tiers.map(&:class).should == [Plink::Tier, Plink::Tier, Plink::Tier]
      subject.detail_text.should == 'one text'
      subject.is_new.should == true
      subject.name.should == 'cold wavy'
      subject.promotion_description.should == 'good offer'
      subject.image_url.should == 'fake.jpg'
      subject.id.should == @plink_offer.id
      subject.max_dollar_award_amount.should == 1.43
      subject.end_date.should == 1.day.ago.to_date
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

    subject do
      Plink::Offer.new(
        {
          offer_record: offer,
          virtual_currency_id: 3,
          name: 'cold wavy',
          image_url: 'fake.jpg'
        }
      )
    end

    it 'takes an offer_record and structures it to be handed back' do
      subject.tiers.count.should == 2
      subject.detail_text.should == 'override text'
    end
  end

  context 'when an offer has no tiers' do
    let(:advertiser) { create_advertiser(advertiser_name: 'cold wavy', logo_url: 'fake.jpg') }

    before do
      @plink_offer = create_offer(
        detail_text: 'New and improved',
        advertiser_id: advertiser.id,
        offers_virtual_currencies: [
          new_offers_virtual_currency(
            virtual_currency_id: 3

          )
        ]
      )
    end

    subject do
      Plink::Offer.new(
        {
          offer_record: @plink_offer,
          virtual_currency_id: 3,
          name: 'cold wavy',
          image_url: 'fake.jpg'
        }
      )
    end

    it 'does not blow up when you ask for tier related data' do
      subject.tiers.should == []
      subject.max_dollar_award_amount.should == nil
      subject.tiers_by_minimum_purchase_amount.should == []
      subject.minimum_purchase_amount_tier.should == nil
    end
  end

  describe '.is_expiring?' do
    let(:unexpired_offer) do
      offer = create_offer(advertiser_id: 900)

      Plink::Offer.new(
        offer_record: offer,
        virtual_currency_id: 1,
        name: 'Spackle Mart',
        image_url: 'awkward.jpg',
        is_new: true,
        promotion_description: 'Give the gift of spackle',
        offers_virtual_currencies: [create_offers_virtual_currency(detail_text: 'Spackle! Spackle! Spackle!')]
      )
    end

    let(:expired_offer) do
      offer = create_offer(advertiser_id: 901, start_date: 20.days.ago, end_date: 8.days.ago)
      Plink::Offer.new(
        offer_record: offer,
        virtual_currency_id: 1,
        name: 'Ukulele Mart',
        image_url: 'awkward.jpg',
        is_new: true,
        promotion_description: 'See our vast collection of travel ukuleles!',
        offers_virtual_currencies: [create_offers_virtual_currency(detail_text: 'Ukuleles are the future of music.')]
      )
    end

    let(:soon_to_be_expired_offer) do
      offer = create_offer(advertiser_id: 902, start_date: 25.days.ago, end_date: 6.days.ago)
      Plink::Offer.new(
        offer_record: offer,
        virtual_currency_id: 1,
        name: 'Beanie Mart',
        image_url: 'awkward.jpg',
        is_new: true,
        promotion_description: 'If you liked it then you should have put a beanie on it.',
        offers_virtual_currencies: [create_offers_virtual_currency(detail_text: 'Beanies are the future of headgear.')]
      )
    end

    it 'returns true for an offer that is expiring in under 7 days' do
      soon_to_be_expired_offer.is_expiring?.should be_true
    end

    it 'returns false for an offer that will not be expiring in the next 7 days' do
      unexpired_offer.is_expiring?.should be_false
    end

    it 'returns true for an offer that has already expired' do
      expired_offer.is_expiring?.should be_true
    end

  end

end
