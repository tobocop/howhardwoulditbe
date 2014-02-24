require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'

describe UserRedemptionAttempt do
  describe 'initialize' do
    it 'intitializes with a user_id' do
      user_redemption_attempt = UserRedemptionAttempt.new(345)
      user_redemption_attempt.user_id.should == 345
    end
  end

  describe 'valid?' do
    let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new({345 => true, 543 => false}) }

    before do
      UserRedemptionAttempt.any_instance.stub(:plink_intuit_account_service).and_return(fake_intuit_account_service)
      Plink::FishyService.stub(:user_fishy?).and_return(false)
    end

    it 'returns true if the user has an account and is not fishy' do
      user_redemption_attempt = UserRedemptionAttempt.new(345)

      user_redemption_attempt.valid?.should be_true
    end

    it 'returns false if the user does not have an account' do
      user_redemption_attempt = UserRedemptionAttempt.new(543)

      user_redemption_attempt.should have(1).error_on(:needs_account)
    end

    it 'returns false if the is fishy' do
      Plink::FishyService.should_receive(:user_fishy?).with(345).and_return(true)

      user_redemption_attempt = UserRedemptionAttempt.new(345)

      user_redemption_attempt.should have(1).error_on(:fishy)
    end
  end

  describe 'error_messages' do
    let(:errors) { double(full_messages: ['one', 'two', 'three']) }

    subject(:user_redemption_attempt) { UserRedemptionAttempt.new(345) }

    before do
      user_redemption_attempt.stub(:errors).and_return(errors)
    end

    it 'returns all of the errors joined by a space' do
      user_redemption_attempt.error_messages.should == 'one two three'
    end
  end
end
