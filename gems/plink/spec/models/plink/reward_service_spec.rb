require 'spec_helper'

describe Plink::RewardService do

  before do
    create_reward(name: 'wally mart gift card')
  end

  describe 'get_rewards' do

    it 'returns all rewards and their amounts' do
      rewards = subject.get_rewards
      rewards.size.should == 1

      reward = rewards.first

      reward.class.should == Plink::Reward
      reward.name.should == 'wally mart gift card'
    end
  end
end