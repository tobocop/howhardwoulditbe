require 'spec_helper'

describe Plink::RewardAmount do

  let(:reward_amount_record) {
    new_reward_amount(dollar_award_amount:143, id:34)
  }

  subject {Plink::RewardAmount.new(reward_amount_record)}

  it 'populates its values based on a RewardAmountRecord' do
    subject.dollar_award_amount.should == 143
    subject.id.should == 34
  end
end
