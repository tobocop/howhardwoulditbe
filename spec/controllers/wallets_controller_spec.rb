require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_offer_service'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'
require 'plink/test_helpers/fake_services/fake_hero_promotion_service'

describe WalletsController do
  it_should_behave_like(:tracking_extensions)

  let(:offer) { new_offer }
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

      it 'should assign hero promotions' do
        get :show

        assigns(:hero_promotions).should == ['promotion']
      end

      it 'should assign current tab to wallet' do
        get :show
        assigns(:current_tab).should == 'wallet'
      end

      it 'assigns a @card_link_url' do
        session[:tracking_params] = {
          referrer_id: 123,
          affiliate_id: 456
        }

        Plink::CardLinkUrlGenerator.any_instance.should_receive(:create_url).with(referrer_id: 123, affiliate_id: 456).and_return { 'http://www.mywebsite.example.com' }

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
    let(:user) {create_user}
    let(:user_auto_login_record) { create_user_auto_login(user_id: user.id) }

    context 'for a hash corresponding to a user' do
      it 'redirects them to the wallet path' do
        get :login_from_email, user_token: user_auto_login_record.user_token

        response.should redirect_to wallet_path
      end

      it 'redirects them to the wallet path if the user is already logged in' do
        controller.stub(:contest_notification_for_user).and_return(nil)
        controller.stub(:redirect_white_label_members).and_return(nil)

        set_current_user

        get :login_from_email, user_token: 'notavalidone'

        response.should redirect_to wallet_path
      end

      it 'signs the user in if a token matches' do
        controller.should_receive(:sign_in_user).and_call_original

        get :login_from_email, user_token: user_auto_login_record.user_token
      end
    end

    context 'for a hash that does not correspond to a user' do
      it 'redirects them to the homepage' do
        get :login_from_email, user_token: 'notavalidtoken'

        response.should redirect_to root_path
      end

      it 'shows them a flash message indicating that the link has expired' do
        get :login_from_email, user_token: 'notavalidtoken'

        flash[:notice].should == 'Link expired.'
      end
    end
  end
end
