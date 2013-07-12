require 'spec_helper'

describe Plink::Reward do
  let(:reward_amount) { new_reward_amount }
  #let(:reward_record) { create_reward(name: 'terget', logo_url: 'http://example.com/logo', amounts: [reward_amount], description: 'ermagherd') }

  subject { Plink::Reward.new(
    {
      name: 'terget',
      description: 'ermagherd',
      logo_url: 'http://example.com/logo'

    },
    [reward_amount])
  }

  it 'uses info from an reward record to populate all fields' do
    subject.name.should == 'terget'
    subject.description.should == 'ermagherd'
    subject.logo_url.should == 'http://example.com/logo'
    subject.amounts.size.should == 1
    amount = subject.amounts.first
    amount.class.should == Plink::RewardAmount
  end
end
