require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_offer_service'

describe WalletsController do

  let(:offer) { new_offer }
  let(:user) { mock(Plink::User, id: 5) }

  before(:each) do
    controller.stub(:current_virtual_currency) { stub(id: 1) }
    fake_offer_service = Plink::FakeOfferService.new({1 => [offer]})
    controller.stub(:plink_offer_service) { fake_offer_service }
  end

  describe '#show' do
    it 'redirects to the home page if the user is not logged in' do
      get :show
      response.should be_redirect
    end

    context 'logged in' do
      before do
        controller.stub(:current_user) { user }
        controller.stub(:require_authentication) { true }
      end

      it 'should assign hero promotions' do
        stub_collection = [stub]
        HeroPromotion.stub(:by_display_order) { stub_collection }
        get :show

        assigns(:hero_promotions).should == stub_collection
      end

      it 'should assign current tab to wallet' do
        get :show
        assigns(:current_tab).should == 'wallet'
      end

      it 'assigns @user_has_account' do
        ActiveIntuitAccount.should_receive(:user_has_account?).with(5).and_return(true)

        get :show

        assigns(:user_has_account).should == true
      end

      it 'should display offers' do
        get :show
        assigns(:offers).should == [offer]
      end
    end
  end
end