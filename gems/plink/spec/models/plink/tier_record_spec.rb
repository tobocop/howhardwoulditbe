require 'spec_helper'

describe Plink::TierRecord do

  let(:valid_attributes) {
    {
        start_date: Date.yesterday,
        end_date: Date.tomorrow,
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
