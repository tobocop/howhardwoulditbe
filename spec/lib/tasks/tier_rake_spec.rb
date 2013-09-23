require 'spec_helper'

describe 'tier:update_7_eleven_tiers_20130923', skip_in_build: true do

  include_context 'rake'

  let!(:advertiser) { create_advertiser(advertiser_name: '7 - Eleven') }
  let!(:other_advertiser) { create_advertiser(advertiser_name: 'Withakay' 's Secret') }

  let!(:virtual_currency) { create_virtual_currency }
  let!(:offer) { create_offer(advertiser_id: advertiser.id) }
  let!(:other_offer) { create_offer(advertiser_id: other_advertiser.id) }

  let!(:ovc) { create_offers_virtual_currency(offer_id: offer.id, virtual_currency_id: virtual_currency.id) }
  let!(:tier) { create_tier(offers_virtual_currency_id: ovc.id, minimum_purchase_amount: 1) }

  let!(:other_ovc) { create_offers_virtual_currency(offer_id: other_offer.id, virtual_currency_id: virtual_currency.id) }
  let!(:other_tier) { create_tier(offers_virtual_currency_id: other_ovc.id) }

  it 'end dates the existing 7-Eleven tiers (Plink Points only)' do

    Plink::AdvertiserRecord.any_instance.stub(:find) { advertiser }
    Plink::VirtualCurrency.any_instance.stub(:find_by_subdomain) { virtual_currency }
    Plink::OfferRecord.any_instance.stub(:find) { offer }
    Plink::OffersVirtualCurrencyRecord.any_instance.stub(:find) { ovc }

    before_records = []
    after_records = []

    Plink::TierRecord.tiers_for_advertiser_and_virtual_currency(advertiser.id, virtual_currency.id).each do |tier|
      before_records << tier.id if tier.end_date > Date.today.midnight
    end

    subject.invoke

    Plink::TierRecord.tiers_for_advertiser_and_virtual_currency(advertiser.id, virtual_currency.id).each do |tier|
      after_records << tier.id if tier.end_date > Date.today.midnight
    end

    before_records.size.should == 1
    after_records.size.should == 2

  end

  it 'sets the $7 minimum/70 Plink Point and $20/150 Plink Point award tiers' do
    subject.invoke
    tiers = Plink::TierRecord.tiers_for_advertiser_and_virtual_currency(advertiser.id, virtual_currency.id)
    tiers.each do |tier|
      case
        when tier.end_date < Time.zone.now
          tier.minimum_purchase_amount.should == 1
          tier.end_date.should <= Time.zone.now
        when tier.dollar_award_amount == 0.7
          tier.minimum_purchase_amount.should == 7
          tier.end_date.should >= Time.zone.now
        when tier.dollar_award_amount == 1.5
          tier.minimum_purchase_amount.should == 20
          tier.end_date.should >= Time.zone.now
        else
          p tier
          raise 'Invalid record'
      end
    end

    tiers.size.should == 3

  end

  it 'rolls back the transaction if an exception is raised in the body of the task' do
    Plink::TierRecord.any_instance.stub(:save!) { raise ActiveRecord::ActiveRecordError }
    expect { subject.invoke }.to raise_exception
    Plink::TierRecord.tiers_for_advertiser_and_virtual_currency(advertiser.id, virtual_currency.id).size.should == 1
  end
end