require 'spec_helper'

describe ReferralsController do
  describe '#create' do
    it 'is a redirect' do
      get :create, {user_id: 1, affiliate_id: 2}
      response.should be_redirect
    end

    it 'redirects to the mobile_registration_url if the user is on a mobile device' do
      controller.stub(is_mobile?: true)
      get :create, {user_id: 1, affiliate_id: 2}
      response.should redirect_to('http://www.plink.dev/index.cfm?fuseaction=mobile.register&refer=1&affiliate_id=2')
    end


    it 'adds the user id to the session as referrer_id' do
      get :create, {user_id: 1, affiliate_id: 2}
      session[:referrer_id].should == 1
    end

    it 'adds the affiliate id to the session as affiliate_id' do
      get :create, {user_id: 1, affiliate_id: 2}
      session[:affiliate_id].should == 2
    end
  end
end
