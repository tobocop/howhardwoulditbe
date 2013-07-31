require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_reward_service'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'

describe RewardsController do

  let(:reward) { mock('Plink::Reward', name: 'the best reward') }
  let(:virtual_currency_presenter) { VirtualCurrencyPresenter.new(virtual_currency: new_virtual_currency(name: 'Plink points')) }
  let(:reward_presenter) { RewardPresenter.new(reward: reward, virtual_currency_presenter: virtual_currency_presenter) }
  let(:mock_account_service) { Plink::FakeIntuitAccountService.new(55 => true) }

  describe 'GET index' do
    before do
      set_current_user(id: 55)
      fake_reward_service = Plink::FakeRewardService.new([reward])
      controller.stub(plink_reward_service: fake_reward_service)
      controller.stub(plink_intuit_account_service: mock_account_service)
      controller.stub(current_virtual_currency: virtual_currency_presenter)
    end

    it 'should be successful' do
      get :index
      response.should be_succes
    end

    it 'should set @rewards' do
      get :index
      assigns(:rewards).length.should == 1
      assigns(:rewards).first.should be_instance_of RewardPresenter
      assigns(:rewards).first.name.should == 'the best reward'
    end

    it 'assigns @user_has_account' do
      get :index

      assigns(:user_has_account).should == true
    end

    it 'assigns current_tab' do
      get :index
      assigns(:current_tab).should == 'rewards'
    end
  end

end