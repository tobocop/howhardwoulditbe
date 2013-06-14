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
    it "sets a user_session object" do
      user_session = stub(valid?: nil)
      UserSession.stub(:new) { user_session }
      post :create, {user_session: {}}
      assigns(:user_session).should == user_session
    end

    describe 'happy path' do
      it 'sets the session current user id if UserSession is valid and redirects' do
        user = stub(id: 123)
        user_session = stub(valid?: true, user: user)
        UserSession.should_receive(:new).with(email: 'bob@example.com', password: 'test123') { user_session }
        post :create, {user_session: {email: 'bob@example.com', password: 'test123'}}

        session[:current_user_id].should == 123
        response.should be_redirect
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