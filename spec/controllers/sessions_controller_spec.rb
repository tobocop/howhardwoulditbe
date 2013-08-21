require 'spec_helper'
require 'plink/test_helpers/fake_services/fake_intuit_account_service'

describe SessionsController do
  describe '#create' do
    describe 'happy path' do
      let(:user) {stub(:user, id: 123).as_null_object}
      let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new }
      let(:user_session)  {stub(valid?: true, user: user, user_id: 123, first_name: 'Bob', email: 'bob@example.com')}

      before do
        UserSession.stub(:new).and_return(user_session)
        controller.stub(plink_intuit_account_service: fake_intuit_account_service)
      end

      it 'signs the user in' do
        UserSession.should_receive(:new).with(email: 'bob@example.com', password: 'test123') { user_session }

        post :create, {user_session: {email: 'bob@example.com', password: 'test123'}}

        session[:current_user_id].should == 123
        response.should be_success
      end

      context 'when the user has a linked card' do
        let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new(123 => true) }

        it 'redirects to the wallet page' do
          post :create, {user_session: {email: 'bob@example.com', password: 'test123'}}

          JSON.parse(response.body).should == {"redirect_path" => wallet_path}
        end

      end

      context 'when the user has no linked card' do
        let(:fake_intuit_account_service) { Plink::FakeIntuitAccountService.new(123 => false) }

        it 'sets the redirect url with the link card param' do
          post :create, {user_session: {email: 'bob@example.com', password: 'test123'}}

          JSON.parse(response.body).should == {"redirect_path" => wallet_path(link_card: true)}
        end
      end

      it 'notifies gigya that an existing user has logged in' do
        gigya = mock
        controller.stub(:gigya_connection) { gigya }

        user_session = stub(valid?: true, user: user, user_id: 123, first_name: 'Bob', email: 'bob@example.com')
        UserSession.stub(:new) { user_session }

        gigya.should_receive(:notify_login).with(site_user_id: 123, first_name: 'Bob', email: 'bob@example.com') { stub(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }

        post :create, {user_session: {}}
      end

      it 'sets a cookie based on the parameters specified by Gigya' do
        gigya = mock
        controller.stub(:gigya_connection) { gigya }

        user_session = stub(valid?: true, user: user, user_id: 123, first_name: 'Bob', email: 'bob@example.com')
        UserSession.stub(:new) { user_session }

        gigya.stub(:notify_login) { stub(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }

        cookies.stub(:[]=)
        cookies.should_receive(:[]=).with('plink_gigya', {value: 'myvalue123', path: '/', domain: 'gigya.com'}).and_call_original
        post :create, {user_session: {}}

        cookies['plink_gigya'].should == 'myvalue123'
      end
    end

    describe 'user was not signed in' do
      it 'returns the errors in json' do
        post :create, user_session: {}

        response.status.should == 403

        JSON.parse(response.body).should == {
          'errors' => {
            'email' => ["Email can't be blank"],
            'password' => ["Password can't be blank"],
          }
        }
      end
    end
  end

  describe 'user was signed in' do
    before do
      set_current_user(id: 123)
      set_virtual_currency
    end

    it 'should destroy the user session after log out' do
      session[:current_user_id] = 123

      delete :destroy
      session[:current_user_id].should_not be
    end

    it 'redirects the user to the home page after they are logged out' do
      delete :destroy
      response.should be_redirect
    end

    it 'sets the flash message to tell the user they are signed out' do
      delete :destroy
      flash[:notice].should == 'You have been successfully logged out.'
    end
  end
end
