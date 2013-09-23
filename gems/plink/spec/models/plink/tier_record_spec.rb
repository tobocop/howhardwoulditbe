require 'spec_helper'

describe Plink::TierRecord do

  let(:valid_attributes) {
    {
      start_date: 1.day.ago,
      end_date: 1.day.from_now,
      dollar_award_amount: 100,
      minimum_purchase_amount: 199,
      offers_virtual_currency_id: 2,
      percent_award_amount: 2.0
    }
  }

  it 'can be valid' do
    Plink::TierRecord.create(valid_attributes).should be_persisted
  end

  it 'provides a nicer API for legacy column names' do
    tier = Plink::TierRecord.new(valid_attributes)

    tier.dollar_award_amount.should == 100
    tier.minimum_purchase_amount.should == 199
  end

  it 'defaults minimum_purchase_amount to 0' do
    tier = Plink::TierRecord.new(valid_attributes.merge(minimum_purchase_amount: nil))
    tier.minimum_purchase_amount.should == 0
  end
end

describe 'named scopes' do

  let!(:virtual_currency) { create_virtual_currency }
  let!(:other_virtual_currency) { create_virtual_currency(subdomain: 'foo') }
  let!(:advertiser) { create_advertiser }
  let!(:other_advertiser) { create_advertiser }

  let!(:offer_1_good_advertiser) { create_offer(advertiser_id: advertiser.id) }
  let!(:offer_2_good_advertiser) { create_offer(advertiser_id: advertiser.id) }
  let!(:offer_3_bad_advertiser) { create_offer(advertiser_id: other_advertiser.id) }

  let!(:offer_1_ovc) {
    create_offers_virtual_currency(
      offer_id: offer_1_good_advertiser.id,
      virtual_currency_id: virtual_currency.id
    )
  }

  let!(:offer_2_ovc) {
    create_offers_virtual_currency(
      offer_id: offer_2_good_advertiser.id,
      virtual_currency_id: other_virtual_currency.id
    )
  }

  let!(:offer_3_ovc) {
    create_offers_virtual_currency(
      offer_id: offer_3_bad_advertiser.id,
      virtual_currency_id: virtual_currency.id
    )
  }

  let!(:offer_3_other_ovc) {
    create_offers_virtual_currency(
      offer_id: offer_3_bad_advertiser.id,
      virtual_currency_id: other_virtual_currency.id
    )
  }

  let!(:tier_offer_1) { create_tier(offers_virtual_currency_id: offer_1_ovc.id) }
  let!(:tier_offer_2) { create_tier(offers_virtual_currency_id: offer_2_ovc.id) }
  let!(:tier_offer_3) { create_tier(offers_virtual_currency_id: offer_3_ovc.id) }
  let!(:tier_offer_3_other_ovc) { create_tier(offers_virtual_currency_id: offer_3_other_ovc.id) }

  describe '.tiers_for_advertiser' do
    let(:scope) { Plink::TierRecord.tiers_for_advertiser(advertiser.id) }

    it 'returns defined tiers for the correct advertiser' do
      scope.should include tier_offer_1
      scope.should include tier_offer_2
    end

    it 'does not return tiers associated with other advertisers' do
      scope.should_not include tier_offer_3
      scope.should_not include tier_offer_3_other_ovc
    end
  end

  describe '.tiers_for_virtual_currency' do
    let(:scope) { Plink::TierRecord.tiers_for_virtual_currency(virtual_currency.id) }

    it 'returns defined tiers for the correct virtual currency' do
      scope.should include tier_offer_1
      scope.should include tier_offer_3
    end

    it 'does not return tiers associated with other virtual currencies' do
      scope.should_not include tier_offer_2
      scope.should_not include tier_offer_3_other_ovc
    end
  end

  describe '.tiers_for_advertiser_and_virtual_currency' do
    let(:scope) { Plink::TierRecord.tiers_for_advertiser_and_virtual_currency(advertiser.id, virtual_currency.id) }

    it 'returns defined tiers for the correct advertiser and virtual currency' do
      scope.should include tier_offer_1
    end

    it 'does not return tiers associated with other advertisers' do
      scope.should_not include tier_offer_3
    end

    it 'does not return tiers associated with other virtual currencies' do
      scope.should_not include tier_offer_2
      scope.should_not include tier_offer_3_other_ovc
    end
  end
end
