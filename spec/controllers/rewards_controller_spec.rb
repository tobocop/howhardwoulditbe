require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_reward_service'

describe RewardsController do

  let(:reward) { mock('Plink::Reward') }

  describe 'GET index' do
    before do
      fake_reward_service = Plink::FakeRewardService.new([reward])
      controller.stub(plink_reward_service: fake_reward_service)
    end

    it 'should be successful' do
      get :index
      response.should be_succes
    end

    it 'should set @rewards' do
      get :index
      assigns(:rewards).should == [reward]
    end

    it 'assigns current_tab' do
      get :index
      assigns(:current_tab).should == 'rewards'
    end
  end

end