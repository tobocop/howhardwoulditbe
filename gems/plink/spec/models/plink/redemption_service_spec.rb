require 'spec_helper'

describe Plink::RedemptionService do

  describe 'create' do

    let(:user) { create_user }
    let(:reward) { create_reward }
    let(:reward_amount) { create_reward_amount(dollar_award_amount: 5, reward_id: reward.id) }

    it 'awards a user based on an reward_amount_id and user_id' do
      redemption = Plink::RedemptionService.new.create(reward_amount_id: reward_amount.id, user_id: user.id, user_balance: 6)

      redemption.dollar_award_amount.should == 5
      redemption.is_pending.should == true
      redemption.is_active.should == true
    end

    it 'rejects the redemption if the user cant afford the reward' do
      Plink::RedemptionService.new.create(reward_amount_id: reward_amount.id, user_id: user.id, user_balance: 3).should == false
    end
  end
end