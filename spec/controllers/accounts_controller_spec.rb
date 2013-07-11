require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'

describe AccountsController do

  let(:user) { stub(id: 10) }

  let(:intuit_account) {
    Plink::ActiveIntuitAccount.new(account_name: 'account', bank_name: 'bank', account_number_last_four: 1234)
  }

  let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new({10 => intuit_account}) }

  let(:debits_credit) {
    Plink::DebitsCredit.new(
      mock('Plink::DebitCreditRecord', {
        is_reward: false,
        award_display_name: 'derp',
        dollar_award_amount: 1.23,
        display_currency_name: 'Plink Pointers',
        currency_award_amount: '123',
        created: Date.parse('2012-07-09'),
        award_type: 'my award'
      })
    )
  }

  let(:fake_currency_activity_service) { mock("CurrencyService", get_for_user_id: [debits_credit, debits_credit]) }

  before(:each) do
    controller.stub(user_logged_in?: true)
    controller.stub(current_user: user)
    controller.stub(plink_intuit_account_service: fake_intuit_account_service)
    controller.stub(plink_currency_activity_service: fake_currency_activity_service)
  end

  describe 'GET show' do
    it 'assigns current_tab' do
      get :show
      assigns(:current_tab).should == 'account'
    end

    it 'assigns @user_has_account' do
      get :show

      assigns(:user_has_account).should == true
    end

    it 'assigns a @card_link_url' do
      session[:referrer_id] = 123
      session[:affiliate_id] = 456
      Plink::CardLinkUrlGenerator.stub(:create_url).with(referrer_id: 123, affiliate_id: 456) { 'http://www.mywebsite.com' }

      get :show

      assigns(:card_link_url).should == 'http://www.mywebsite.com'
    end

    it 'assigns an @bank_account' do
      get :show
      assigns(:bank_account).should == intuit_account
    end

    it 'assigns a @currency_activity' do
      fake_currency_activity_service.should_receive(:get_for_user_id).with(10).and_return(['1'])
      CurrencyActivityPresenter.should_receive(:build_currency_activity).with('1').and_return('presented activity')

      get :show
      assigns(:currency_activity).should == ['presented activity']
    end

    it 'redirects if the current user is not logged in' do
      controller.stub(user_logged_in?: false)
      get :show
      response.should be_redirect
    end
  end
end
