require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_offer_service'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'
require 'plink/test_helpers/fake_services/fake_hero_promotion_service'

describe WalletsController do
  it_should_behave_like(:tracking_extensions)
  it_should_behave_like(:auto_login_extensions)

  let(:offer) { new_offer }
  let(:hero_promotion_service) { double }
  let(:hero_promotion) { double }
  let(:wallet_item) { new_locked_wallet_item }
  let(:wallet) { stub(id:2, sorted_wallet_item_records: [wallet_item]) }

  before do
    set_virtual_currency({id: 1})

    controller.stub(:plink_hero_promotion_service).and_return(Plink::FakeHeroPromotionService.new(['promotion']))
    Plink::WalletRecord.stub(:find).and_return(wallet)

    fake_offer_service = Plink::FakeOfferService.new({1 => [offer]})
    controller.stub(:plink_offer_service) { fake_offer_service }

    fake_account_service = Plink::FakeIntuitAccountService.new({5 => true})
    controller.stub(:plink_intuit_account_service) { fake_account_service }
  end

  describe '#show' do
    before do
      set_current_user(id: 5, wallet: wallet)
      controller.unstub(:plink_hero_promotion_service)
    end

    it 'redirects to the home page if the user is not logged in' do
      set_current_user(logged_in?: false)

      get :show

      response.should be_redirect
    end

    context 'logged in' do
      before do
        controller.stub(:require_authentication) { true }
      end

      it 'assigns hero promotions' do
        controller.stub(:plink_hero_promotion_service).and_return(hero_promotion_service)

        hero_promotion_service.should_receive(:active_for_user).with(5, anything).
          and_return([hero_promotion])

        get :show

        assigns(:hero_promotions).should_not be_empty
      end

      it 'assigns current_tab to wallet' do
        get :show
        assigns(:current_tab).should == 'wallet'
      end

      it 'assigns card_link_url' do
        session[:tracking_params] = {
          referrer_id: 123,
          affiliate_id: 456
        }

        Plink::CardLinkUrlGenerator.any_instance.should_receive(:create_url).
          with(referrer_id: 123, affiliate_id: 456).
          and_return { 'http://www.mywebsite.example.com' }

        get :show

        assigns(:card_link_url).should == 'http://www.mywebsite.example.com'
      end

      it 'assigns user_has_account' do
        get :show

        assigns(:user_has_account).should == true
      end

      it 'should display offers' do
        get :show
        assigns(:offers).map(&:class).should == [OfferItemPresenter]
      end

      it 'should display wallet items' do
        get :show
        assigns(:wallet_items).length.should == 1
        assigns(:wallet_items).first.should be_instance_of WalletItemPresenter::LockedWalletItemPresenter
      end
    end
  end

  describe 'GET login_from_email' do
    it 'calls auto_login_user from AutoLoginExtenstions' do
      controller.should_receive(:auto_login_user).
        with('my_url_token', wallet_path).
        and_call_original

      get :login_from_email, user_token: 'my_url_token'
      response.should redirect_to(root_url)
    end
  end
end
