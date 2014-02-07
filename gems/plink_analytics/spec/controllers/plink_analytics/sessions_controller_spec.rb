require 'spec_helper'

describe PlinkAnalytics::SessionsController do
  describe 'GET new' do
    let(:login_form) { double }

    before do
      PlinkAnalytics::LoginForm.stub(:new).and_return(login_form)
    end

    it 'should be successful' do
      get :new

      response.should be_successful
    end

    it 'assigns a login_form' do
      get :new

      assigns(:login_form).should == login_form
    end
  end

  describe 'POST create' do
    let(:login_form) { double(PlinkAnalytics::LoginForm, valid?: false) }
    let(:login_attempt_params) { {'email' => 'myemail@plink.com', 'password' => 'valid'} }

    before do
      PlinkAnalytics::LoginForm.stub(:new).and_return(login_form)
    end

    it 'initializes a login_form from the params' do
      PlinkAnalytics::LoginForm.should_receive(:new).with(login_attempt_params).and_return(login_form)

      post :create, login_attempt: login_attempt_params
    end

    context 'when valid? returns true' do
      let(:login_form) { double(PlinkAnalytics::LoginForm, valid?: true, id: 3) }

      before do
        post :create, login_attempt: login_attempt_params
      end

      it 'stores the login_forms id in the session as contact_id' do
        session[:contact_id].should == 3
      end

      it 'redirects to the market market share page' do
        response.should redirect_to '/market_share'
      end
    end

    context 'when valid? returns false' do
      let(:login_form) { double(PlinkAnalytics::LoginForm, valid?: false) }

      it 'renders the new template' do
        post :create, login_attempt: login_attempt_params

        response.should render_template 'new'
      end
    end
  end
end
