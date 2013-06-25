require 'spec_helper'

describe AccountsController do
  let(:user) { new_user }

  before(:each) do
    controller.stub(current_user: user)
  end

  describe 'GET show' do
    it 'assigns current_tab' do
      get :show
      assigns(:current_tab).should == 'account'
    end

    it 'assigns @user_has_account' do
      ActiveIntuitAccount.count.should == 0

      get :show

      assigns(:user_has_account).should == false
    end

    it 'assigns a @card_link_url' do
      session[:referrer_id] = 123
      session[:affiliate_id] = 456
      Plink::CardLinkUrlGenerator.stub(:create_url).with(referrer_id: 123, affiliate_id: 456) { 'http://www.mywebsite.com' }

      get :show

      assigns(:card_link_url).should == 'http://www.mywebsite.com'
    end
  end
end
