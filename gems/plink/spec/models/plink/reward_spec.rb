require 'spec_helper'

describe Plink::Reward do
  let(:reward_record) { create_reward(name: 'terget', amounts: [new_reward_amount]) }

  subject { Plink::Reward.new(reward_record) }

  it 'uses info from an reward record to populate all fields' do
    subject.name.should == 'terget'
    subject.amounts.size.should == 1
    amount = subject.amounts.first
    amount.class.should == Plink::RewardAmount
  end
end
