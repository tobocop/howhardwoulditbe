require 'spec_helper'

describe RedemptionController do
  before do
    set_current_user({id: 134})
    set_virtual_currency
  end

  describe 'GET show' do
    let(:mock_reward) { double(:reward) }
    let(:mock_plink_reward_service) { double(:plink_reward_service, for_reward_amount: mock_reward) }

    before do
      controller.stub(plink_reward_service: mock_plink_reward_service)
    end

    it 'redirects to the rewards page when no reward amount can be found' do
      get :show

      assigns(:reward).should == mock_reward
    end

    pending 'does not allow for reward redemption'
  end

  describe 'POST create' do
    let(:fake_reward_redemption_service) { double(redeem: true) }
    let(:user_redemption_attempt) { double(UserRedemptionAttempt, valid?: true, error_messages: 'my reason') }

    before do
      controller.stub(plink_redemption_service: fake_reward_redemption_service)
      UserRedemptionAttempt.stub(:new).and_return(user_redemption_attempt)
    end

    it 'should require the user to be signed in' do
      controller.should_receive(:require_authentication)
      post :create
    end

    it 'should require the user to have a card linked' do
      post :create
    end

    it 'redirect to the rewards page and also sets a flash error message when a user cannot redeem' do
      user_redemption_attempt.stub(:valid?).and_return(false)

      post :create

      response.should redirect_to rewards_path
      flash[:error].should == 'my reason'
    end

    it 'redirect to the rewards page and also sets a flash error message when a redemption can not be created' do
      fake_reward_redemption_service.stub(redeem: false)

      post :create, reward_amount_id: 5

      response.should redirect_to rewards_path
      flash[:error].should == 'You do not have enough points to redeem.'
    end

    it 'redirect to the rewards page when a redemption is successfully created' do
      fake_reward_redemption_service.should_receive(:redeem)
      post :create, reward_amount_id: 5
      response.should redirect_to redemption_path(reward_amount_id: 5)
    end

    it 'handles Tango redemption failures with a message to the user' do
      fake_reward_redemption_service.unstub(:redeem)
      fake_reward_redemption_service.stub(:redeem).and_raise('Tango Redemption failed')

      post :create, reward_amount_id: 5

      response.should redirect_to rewards_path
      flash[:error].should == 'Unable to reach Tango. Please try again later.'
    end
  end
end
