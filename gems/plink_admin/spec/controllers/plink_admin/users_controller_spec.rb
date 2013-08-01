require 'spec_helper'

describe PlinkAdmin::UsersController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET search' do

    let(:mock_user_service) { mock(:user_service, search_by_email: []) }

    before do
      controller.stub(plink_user_service: mock_user_service)
    end

    it 'searches by the email param' do
      get :search, email: 'user@example.com'

      assigns(:users).should == []
    end

    it 'assigns the search term' do
      get :search, email: 'user@example.com'

      assigns(:search_term).should == 'user@example.com'
    end

    it 'renders the index view' do
      get :search, email: 'user@example.com'

      response.should render_template :index
    end
  end

  describe 'POST impersonate' do
    let(:fake_signin) { mock(:signin_stub, signin: nil) }

    before do
      PlinkAdmin.impersonation_redirect_url = '/somewhere'
      PlinkAdmin.sign_in_user = ->(user_id, session) { fake_signin.signin(user_id, session) }
    end

    it 'should sign in the user and redirect to the configured path' do
      fake_signin.should_receive(:signin).with('776', session)

      post :impersonate, id: '776'

      response.should redirect_to '/somewhere'
    end
  end

  describe 'POST stop_impersonating' do
    let(:fake_signout) { mock(:signout_stub, signout: nil) }

    before do
      PlinkAdmin.sign_out_user = ->(session) { fake_signout.signout(session) }
    end

    it 'should sign out the user and redirect to the root path' do
      fake_signout.should_receive(:signout).with(session)

      post :stop_impersonating, id: '456'

      response.should redirect_to '/'
    end
  end
end
