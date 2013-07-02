require 'spec_helper'

describe Plink::RewardService do

  before do
    create_reward(name: 'wally mart gift card', amounts: [
        new_reward_amount(dollar_award_amount: 123, is_active: true),
        new_reward_amount(dollar_award_amount: 321, is_active: false)
    ])
    create_reward(name: 'not to be found card', is_active: false, amounts: [
        new_reward_amount(dollar_award_amount: 123, is_active: true)
    ])
  end

  describe 'get_live_rewards' do

    it 'returns all rewards and their amounts' do
      rewards = subject.get_live_rewards
      rewards.size.should == 1

      reward = rewards.first

      reward.class.should == Plink::Reward
      reward.name.should == 'wally mart gift card'

      reward.amounts.count.should == 1
    end
  end
end