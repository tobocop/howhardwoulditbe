require 'spec_helper'

describe RedemptionsController do
  describe 'POST create' do

    let(:user) { stub(id: 134, logged_in?: true, current_balance: 987, first_name: 'test_name', email: 'test@test.com') }
    let(:fake_reward_redemption_service) { stub(redeem: true) }

    before do
      controller.stub(current_user: user)
      ActiveIntuitAccount.stub(user_has_account?: true)
      controller.stub(plink_redemption_service: fake_reward_redemption_service)
    end

    it 'should require the user to be signed in' do
      controller.should_receive(:require_authentication)
      post :create
    end

    it 'should require the user to have a card linked' do
      ActiveIntuitAccount.should_receive(:user_has_account?).with(134) { true }

      post :create
    end

    it 'redirect to the rewards page and also sets a flash error message when a user does not have a card linked' do
      ActiveIntuitAccount.should_receive(:user_has_account?).with(134) { false }

      post :create

      response.should redirect_to rewards_path
      flash[:error].should == 'You must have a linked card to redeem an award.'
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
      response.should redirect_to rewards_path
    end

  end
end