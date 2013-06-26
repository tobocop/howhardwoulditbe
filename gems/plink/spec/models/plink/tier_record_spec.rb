require 'spec_helper'

describe Plink::TierRecord do

  let(:valid_attributes) {
    {
        start_date: Date.yesterday,
        end_date: Date.tomorrow,
        dollar_award_amount: 100,
        minimum_purchase_amount: 199,
        offers_virtual_currency_id: 2
    }
  }

  it 'can be valid' do
    create_tier(valid_attributes).should be_valid
  end

  it 'provides a nicer API for legacy column names' do
    tier = new_tier(valid_attributes)

    tier.dollar_award_amount.should == 100
    tier.minimum_purchase_amount.should == 199
  end
end
