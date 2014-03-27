require 'spec_helper'

describe PlinkAdmin::UsersController do
  let(:admin) { create_admin }

  before do
    Plink::FishyService.stub(:fishy_with).and_return([])
    sign_in :admin, admin
  end

  describe 'GET edit' do
    let(:wallet) { double(:wallet, id: 30) }
    let(:user) { double(Plink::UserRecord, id: 200, wallet: wallet) }
    let(:users_institutions) { [double] }
    let(:unlock_reasons) { {'app_install_promotion'=>'app_install_promotion', 'join'=>'join', 'promotion'=>'promotion', 'referral'=>'referral', 'transaction'=>'transaction'} }
    let(:plink_user_record) { double(Plink::UserRecord, scoped: true, find: user) }
    let(:reward_record) { double(Plink::RewardRecord) }
    let(:duplicate_registration_attempts) { [double(Plink::DuplicateRegistrationAttemptRecord)] }

    before do
      controller.stub(:plink_user_record).and_return(plink_user_record)
      Plink::UsersInstitutionRecord.stub_chain(:find_by_user_id, :order).
        and_return(users_institutions)
      Plink::RewardRecord.stub_chain(:live, :order).and_return([reward_record])
      Plink::DuplicateRegistrationAttemptRecord.stub(:duplicates_by_user_id).and_return(duplicate_registration_attempts)
    end

    it 'assigns user to the user whose :id is passed as a parameter' do
      plink_user_record.should_receive(:find).with('200').and_return(user)

      get :edit, id: 200

      assigns(:user).should == user
    end

    it 'assigns unlock_reasons' do
      get :edit, id: 200

      assigns(:unlock_reasons).should == unlock_reasons
    end

    it 'assigns wallet_id to the users wallet.id' do
      get :edit, id: 200

      assigns(:wallet_id).should == user.wallet.id
    end

    it 'assigns the users institutions' do
      get :edit, id: 200

      assigns(:users_institutions).should == users_institutions
    end

    it 'assigns the users fishy status' do
      Plink::FishyService.stub(:fishy_with).and_return([1234, 6789])

      get :edit, id: 200

      assigns(:fishy_status).should == 'Fishy'
    end

    it 'assigns fishy users' do
      Plink::FishyService.should_receive(:fishy_with).with(user.id).and_return([1234, 6789])

      get :edit, id: 200

      assigns(:fishy_user_ids).should == [1234, 6789]
    end

    it 'assigns all available rewards' do
      where = double
      Plink::RewardRecord.should_receive(:live).with().and_return(where)
      where.should_receive(:order).with('name').and_return([reward_record])

      get :edit, id: 200

      assigns(:rewards).should == [reward_record]
    end

    it 'assigns duplicate_registrations available rewards' do
      Plink::DuplicateRegistrationAttemptRecord.should_receive(:duplicates_by_user_id).with(200).and_return(duplicate_registration_attempts)

      get :edit, id: 200

      assigns(:duplicate_registrations).should == duplicate_registration_attempts
    end
  end

  describe 'GET search' do
    let(:user_mock) { mock(:user) }
    let(:mock_user_service) { mock(:user_service, search_by_email: [user_mock]) }

    before { controller.stub(plink_user_service: mock_user_service) }

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

  describe 'PUT update' do
    let(:user) { double(Plink::UserRecord) }
    let(:plink_user_record) { double(Plink::UserRecord, scoped: true, find: user) }
    let(:update_manager) { double(PlinkAdmin::UserUpdateWithActiveStateManager, update_attributes: true) }
    before do
      controller.stub(:plink_user_record).and_return(plink_user_record)
      controller.stub(:user_data)
      PlinkAdmin::UserUpdateWithActiveStateManager.stub(:new).and_return(update_manager)
    end

    it 'assigns user to the user whose :id was passed as a parameter' do
      plink_user_record.should_receive(:find).with('200').and_return(user)

      put :update, {id: 200, user: {email: 'updated@email_address.com'}}

      assigns(:user).should == user
    end

    it 'creates the update decorator with the user that was found' do
      PlinkAdmin::UserUpdateWithActiveStateManager.should_receive(:new).
        with(user).
        and_return(update_manager)

      put :update, {id: 200, user: {email: 'updated@email_address.com'}}
    end

    it 'calls the update with the passed in id and params' do
      update_manager.should_receive(:update_attributes).
        with({'email' => 'updated@email_address.com'}).
        and_return(true)

      put :update, {id: 200, user: {email: 'updated@email_address.com'}}
    end

    it 'renders the edit form' do
      put :update, {id: 200, user: {email: 'updated@email_address.com'}}

      response.should render_template :edit
    end

    context 'when the update is successful' do
      it 'sets the flash message to success' do
        put :update, {id: 200, user: {email: 'updated@email_address.com'}}

        flash[:notice].should == 'User successfully updated'

      end
    end

    context 'when the update is not successful' do
      before { update_manager.stub(:update_attributes).and_return(false) }

      it 'sets the flash message to a failure message' do
        put :update, {id: 200, user: {email: 'updated@email_address.com'}}

        flash[:notice].should == 'User could not be updated'
      end
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
