require 'spec_helper'

describe Plink::Tier do
  let(:tier_record) {
    new_tier(dollar_award_amount: 100, minimum_purchase_amount: 200)
  }

  subject { Plink::Tier.new(tier_record) }

  it 'uses a tier record to populate its data' do
    subject.dollar_award_amount.should == 100
    subject.minimum_purchase_amount.should  == 200
  end
end
