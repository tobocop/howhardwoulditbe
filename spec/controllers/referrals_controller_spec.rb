require 'spec_helper'

describe ReferralsController do
  describe '#create' do
    before do
      get :create, {user_id: 1, affiliate_id: 2}
    end

    it 'is a redirect to the root_path' do
      response.should be_redirect
    end

    it 'adds the user id to the session as referrer_id' do
      session[:referrer_id].should == 1
    end

    it 'adds the affiliate id to the session as affiliate_id' do
      session[:affiliate_id].should == 2
    end

    it 'tracks the affiliate id to the session tracking_params' do
      session[:tracking_params][:affiliate_id].should == '2'
    end

    context 'when the user is on a mobile device' do
      before do
        controller.stub(is_mobile?: true)
        get :create, {user_id: 1, affiliate_id: 2}
      end

      it 'redirects to the mobile_registration_url if the user is on a mobile device' do
        response.should redirect_to('http://www.plink.dev/index.cfm?fuseaction=mobile.register&refer=1&affiliate_id=2')
      end
    end
  end
end
