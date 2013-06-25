require 'spec_helper'

describe ReferralsController do
  describe '#create' do
    it 'is a redirect' do
      get :create, {user_id: 1, affiliate_id: 2}
      response.should be_redirect
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