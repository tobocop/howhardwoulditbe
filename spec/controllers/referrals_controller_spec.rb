require 'spec_helper'

describe ReferralsController do
  it_should_behave_like(:tracking_extensions)

  describe '#create' do
    before do
      get :create, {user_id: 1, affiliate_id: 2}
    end

    it 'is a redirect to the root_path' do
      response.should be_redirect
    end

    it 'tracks the referrer id to the session tracking_params' do
      session[:tracking_params][:referrer_id].should == '1'
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
