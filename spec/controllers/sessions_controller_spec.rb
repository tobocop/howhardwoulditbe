require 'spec_helper'

describe SessionsController do
  describe '#new' do
    it "sets a user_session object" do
      get :new
      assigns(:user_session).should be_a(UserSession)
    end

    it "is successful" do
      get :new
      response.should be_success
    end
  end

  describe '#create' do
    it 'sets a user_session object' do
      user_session = stub(valid?: nil)
      UserSession.stub(:new) { user_session }
      post :create, {user_session: {}}
      assigns(:user_session).should == user_session
    end

    describe 'happy path' do

      it 'sets the session current user id if UserSession is valid and redirects' do
        user = stub(id: 123).as_null_object
        user_session = stub(valid?: true, user: user, user_id: 123, first_name: 'Bob', email: 'bob@example.com')
        UserSession.should_receive(:new).with(email: 'bob@example.com', password: 'test123') { user_session }
        post :create, {user_session: {email: 'bob@example.com', password: 'test123'}}

        session[:current_user_id].should == 123
        response.should be_redirect
      end

      it 'notifies gigya that an existing user has logged in' do
        gigya = mock
        controller.stub(:gigya_connection) { gigya }

        user = stub(id:123).as_null_object
        user_session = stub(valid?: true, user: user, user_id: 123, first_name: 'Bob', email: 'bob@example.com')
        UserSession.stub(:new) { user_session }

        gigya.should_receive(:notify_login).with(site_user_id: 123, first_name: 'Bob', email: 'bob@example.com') { stub(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }

        post :create, {user_session: {}}
      end

      it 'sets a cookie based on the parameters specified by Gigya' do
        gigya = mock
        controller.stub(:gigya_connection) { gigya }

        user = stub(id:123)
        user_session = stub(valid?: true, user: user, user_id: 123, first_name: 'Bob', email: 'bob@example.com')
        UserSession.stub(:new) { user_session }

        gigya.stub(:notify_login) { stub(cookie_name: 'plink_gigya', cookie_value: 'myvalue123', cookie_path: '/', cookie_domain: 'gigya.com') }

        controller.send(:cookies).should_receive(:[]=).with('plink_gigya', { value: 'myvalue123', path: '/', domain: 'gigya.com'}).and_call_original
        post :create, {user_session: {}}

        cookies['plink_gigya'].should == 'myvalue123'
      end
    end

    describe 'user was not signed in' do
      it 're-renders the new template' do
        user_session = stub(valid?: false)
        UserSession.should_receive(:new) { user_session }
        post :create, {user_session: {}}

        response.should render_template('sessions/new')
      end
    end
  end

  describe 'user was signed in' do
    before do
      user = stub(id: 123)
      controller.stub(:current_user) { user }
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