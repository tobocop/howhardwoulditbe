require 'spec_helper'

describe PlinkAdmin::UsersController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET edit' do
    let(:user) { create_user }
    let(:users_institutions) { [double] }
    let(:find_by_user_id) { double(order: users_institutions) }
    let!(:wallet) { create_wallet(user_id: user.id) }
    let(:unlock_reasons) { {'app_install_promotion'=>'app_install_promotion', 'join'=>'join', 'promotion'=>'promotion', 'referral'=>'referral', 'transaction'=>'transaction'} }

    before do
      Plink::UsersInstitutionRecord.stub(:find_by_user_id).and_return(find_by_user_id)
      get :edit, id: user.id
    end

    it 'assigns user to the user whose :id is passed as a parameter' do
      assigns(:user).should == user
    end

    it 'assigns unlock_reasons' do
      assigns(:unlock_reasons).should == unlock_reasons
    end

    it 'assigns wallet_id to the users wallet.id' do
      assigns(:wallet_id).should == user.wallet.id
    end

    it 'assigns the users institutions' do
      assigns(:users_institutions).should == users_institutions
    end
  end

  describe 'GET search' do
    let(:user_mock) { mock(:user) }
    let(:mock_user_service) { mock(:user_service, search_by_email: [user_mock]) }

    before do
      controller.stub(plink_user_service: mock_user_service)
    end

    it 'searches by the email param' do
      get :search, email: 'user@example.com'

      assigns(:users).should == [user_mock]
    end

    it 'searches by the id param' do
      mock_user_service.should_receive(:find_by_id).with('1').and_return(user_mock)

      get :search, user_id: 1

      assigns(:users).should == [user_mock]
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
