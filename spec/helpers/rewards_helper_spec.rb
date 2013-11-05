require 'spec_helper'

describe RewardsHelper do
  describe '#display_as_available?' do
    let(:current_user) { double(can_redeem?: true, current_balance: 50) }

    before do
      helper.stub(:current_user).and_return(current_user)
      Plink::RewardAmount.stub(:MAXIMUM_REDEMPTION_VALUE).and_return(100)
    end

    it "returns true if dollar amount is less than the user's account balance" do
      helper.display_as_available?(true, 10, true).should be_true
    end

    it "returns false if dollar amount is greater than the user's account balance" do
      helper.display_as_available?(true, 51, true).should be_false
    end

    it 'returns true if dollar amount is less than the maximum redemption value' do
      helper.display_as_available?(true, 10, true).should be_true
    end

    it 'returns false if dollar amount is more than the maximum redemption value' do
      helper.display_as_available?(true, 101, true).should be_false
    end

    it 'returns false if the reward is not redeemable' do
      helper.display_as_available?(true, 10, false).should be_false
    end

    it 'returns false if the user does not have an account' do
      helper.display_as_available?(false, 10, true).should be_false
    end

    it 'returns false if the user cannot redeem' do
      helper.unstub(:current_user)
      helper.stub(:current_user).and_return(double(can_redeem?: false))

      helper.display_as_available?(true, 10, true).should be_false
    end
  end
end
