require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_offer_service'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'
require 'plink/test_helpers/fake_services/fake_hero_promotion_service'

describe WalletsController do

  let(:offer) { new_offer }
  let(:wallet_item) { new_locked_wallet_item }
  let(:wallet) { stub(id:2, wallet_item_records: [wallet_item]) }

  let(:user) { mock(Plink::UserRecord, id: 5, wallet: wallet, logged_in?:true) }

  let(:virtual_currency) { stub(id: 1) }

  before(:each) do
    controller.stub(:plink_hero_promotion_service).and_return(Plink::FakeHeroPromotionService.new(['promotion']))
    Plink::WalletRecord.stub(:find).and_return(wallet)

    controller.stub(:current_user) { user }
    controller.stub(:current_virtual_currency) { virtual_currency }

    fake_offer_service = Plink::FakeOfferService.new({1 => [offer]})
    controller.stub(:plink_offer_service) { fake_offer_service }

    fake_account_service = Plink::FakeIntuitAccountService.new({5 => true})
    controller.stub(:plink_intuit_account_service) { fake_account_service }
  end

  describe '#show' do
    it 'redirects to the home page if the user is not logged in' do
      controller.stub(:current_user) { stub(logged_in?:false) }
      get :show
      response.should be_redirect
    end

    context 'logged in' do
      before do
        controller.stub(:require_authentication) { true }
      end

      it 'should assign hero promotions' do
        get :show

        assigns(:hero_promotions).should == ['promotion']
      end

      it 'should assign current tab to wallet' do
        get :show
        assigns(:current_tab).should == 'wallet'
      end

      it 'assigns a @card_link_url' do
        Plink::CardLinkUrlGenerator.any_instance.stub(:create_url) { 'http://www.mywebsite.example.com' }

        get :show

        assigns(:card_link_url).should == 'http://www.mywebsite.example.com'
      end

      it 'assigns @user_has_account' do
        get :show

        assigns(:user_has_account).should == true
      end

      it 'should display offers' do
        get :show
        assigns(:offers).should == [offer]
      end

      it 'should display wallet items' do
        get :show
        assigns(:wallet_items).length.should == 1
        assigns(:wallet_items).first.should be_instance_of WalletItemPresenter::LockedWalletItemPresenter
      end
    end
  end
end