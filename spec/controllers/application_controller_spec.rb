require 'spec_helper'

require 'plink/test_helpers/fake_services/fake_user_service'

describe ApplicationController do

  controller do
    def index
      render text: 'ok'
    end
  end

  describe '#redirect_white_label_members' do
    it 'signs in the user and redirects users that have a virtual currency from a different subdomain' do
      controller.stub(current_user: mock(:logged_in_user, id: 5, logged_in?: true, password_hash: '123abc'))
      controller.stub(current_virtual_currency: mock(:virtual_currency, subdomain: 'swag'))

      request.host = 'www.test.host'
      cookies[:PLINKUID] = 'EWIFOH123oUI'

      get :index

      response.should redirect_to "http://swag.test.host"
      cookies[:PLINKUID].should == 'EWIFOH123oUI'
    end

    it 'does not redirect if the user is from the www subdomain' do
      controller.stub(current_user: mock(:logged_in_user, id: 5, logged_in?: true, password_hash: '123abc'))
      controller.stub(current_virtual_currency: mock(:virtual_currency, subdomain: 'www'))

      get :index

      response.body.should == 'ok'
    end

    it 'does not redirect if the user is not logged in' do
      controller.stub(:contest_notification_for_user).and_return(false)
      controller.stub(current_user: mock(:logged_out_user, logged_in?: false, id: 1, primary_virtual_currency_id: 3))

      get :index

      response.body.should == 'ok'
    end
  end

  describe '#sign_in_user' do
    let(:user) { mock_model(Plink::UserRecord, id: 123, password_hash: 'hashypassy') }

    it 'sets current_user_id in the session' do
      controller.sign_in_user(user)
      session[:current_user_id].should == 123
    end

    it 'sets the plinkUID cookie for coldfusion to the base64 encoded version of the hashed password' do
      controller.sign_in_user(user)
      cookies[:PLINKUID].should == "aGFzaHlwYXNzeQ==\n"
    end
  end

  describe '#sign_out_user' do
    let(:user) { mock_model(Plink::UserRecord, id: 123, password_hash: 'hashypassy') }

    before :each do
      controller.sign_in_user(user)
    end

    it 'sets the current_user_id in the session to nil' do
      controller.sign_out_user
      session[:current_user_id].should be_nil
    end

    it 'destroys the PLINKUID cookie' do
      controller.sign_out_user
      cookies[:PLINKUID].should be_nil
    end

    it 'destroys the CFID and CFTOKEN if present' do
      cookies[:CFID] = {value: '1234', domain: :all, path: '/'}
      cookies[:CFTOKEN] = {value: '1234', domain: :all, path: '/'}

      controller.sign_out_user
      cookies[:CFID].should be_nil
      cookies[:CFTOKEN].should be_nil
    end
  end

  describe '#current_user' do
    it 'returns the current user' do
      session[:current_user_id] = 3
      user = stub
      user_presenter = stub

      controller.stub(:plink_user_service) { Plink::FakeUserService.new(3 => user) }

      UserPresenter.stub(:new).with(user: user) { user_presenter }

      controller.current_user.should == user_presenter
    end

    it 'returns a NullUserPresenter if the current_user_id is nil' do
      session[:current_user_id] = nil
      controller.current_user.should be_a(NullUserPresenter)
    end
  end

  describe '#current_virtual_currency' do
    it 'returns the correct virtual currency when we have a current_user' do
      currency = create_virtual_currency(name: 'Plonk Points')
      current_user = create_user
      current_user.primary_virtual_currency = currency
      current_user.save!

      session[:current_user_id] = current_user.id

      presented_currency = controller.current_virtual_currency

      presented_currency.currency_name.should == 'Plonk Points'
    end

    it 'returns the default virtual currency when we have a null current user' do
      create_virtual_currency(name: 'Plonk Points', subdomain: Plink::VirtualCurrency::DEFAULT_SUBDOMAIN)
      NullUserPresenter.any_instance.stub(:primary_virtual_currency_id) { Plink::VirtualCurrency.default.id }

      presented_currency = controller.current_virtual_currency

      presented_currency.currency_name.should == 'Plonk Points'
    end
  end

  describe '#require_authentication' do
    before do
      controller.stub(:redirect_to)
    end

    it 'does not redirect if the user is logged in' do
      controller.stub(:user_logged_in?) { true }
      controller.should_not_receive(:redirect_to)
      controller.require_authentication
    end

    it 'it redirects to the home page if the user is not logged in' do
      controller.stub(:user_logged_in?) { false }
      controller.should_receive(:redirect_to).with(root_path)
      controller.require_authentication
    end

    it "keeps the flash" do
      controller.stub(:user_logged_in?) { false }
      flash.should_receive(:keep)
      controller.require_authentication
    end
  end

  describe '#user_logged_in?' do
    it 'returns true if a current user is logged in' do
      controller.stub(:current_user) { stub(logged_in?: true) }
      controller.user_logged_in?.should == true

    end

    it 'it returns false if the user is not logged in' do
      controller.stub(:current_user) { stub(logged_in?: false) }
      controller.user_logged_in?.should == false
    end
  end

  describe '#gigya_connection' do
    it 'initializes and returns a Gigya object with the right credentials' do
      ENV['GIGYA_API_KEY'] = 'my-api-key'
      ENV['GIGYA_SECRET'] = 'secret'
      gigya_stub = stub
      Gigya.should_receive(:new).with(Gigya::Config.instance) { gigya_stub }

      controller.gigya_connection.should == gigya_stub
    end
  end

  describe '#user_must_be_linked' do
    before do
      controller.stub(:current_user) { stub(id: 1) }
    end

    it 'raises if the user is not linked' do
      Plink::IntuitAccountService.any_instance.stub(:user_has_account?).with(1) { false }
      expect { controller.user_must_be_linked }.to raise_error(Exception, 'User account must be linked')
    end

    it 'does not raise if the user is linked' do
      Plink::IntuitAccountService.any_instance.stub(:user_has_account?).with(1) { true }

      expect {
        controller.user_must_be_linked.should be_nil
      }.to_not raise_exception
    end
  end

  describe '#user_registration_form' do
    it 'returns a new registration form object' do
      mock_reg_form = mock("UserRegistationForm")
      UserRegistrationForm.should_receive(:new).and_return { mock_reg_form }

      controller.user_registration_form.should == mock_reg_form
    end
  end

  describe '.auto_login_from_cookie' do
    context 'with a valid cookie' do
      let!(:valid_user) { create_user(email: 'grinch@example.com', password_hash: 'greeneggsandhash') }
      let!(:valid_cookie) { set_auto_login_cookie(valid_user.password_hash) }

      it 'auto logs in the user if a valid cookie is found' do
        controller.stub(:redirect_white_label_members).and_return(false)
        controller.stub(:contest_notification_for_user).and_return(false)

        get :index

        controller.user_logged_in?.should be_true
      end
    end

    context 'with an invalid cookie' do
      let!(:invalid_user) { create_user(email: 'cindylou@example.com', password_hash: 'whohash') }
      let!(:invalid_cookie) { set_auto_login_cookie('stolenbythegrinch') }

      it 'does not log the user in automatically if an invalid cookie is found' do
        get :index
        controller.user_logged_in?.should be_false
      end
    end

    context 'with an expired cookie' do
      let!(:invalid_user) { create_user(email: 'max@example.com', password_hash: 'maxhash') }
      let!(:invalid_cookie) { set_auto_login_cookie('maxhash', expires: 5.minutes.ago) }

      it 'does not log the user in automatically if an expired cookie is found' do
        get :index
        controller.user_logged_in?.should be_false
      end
    end
  end

  describe '#get_return_to_path' do
    it 'returns nil if there is no referer' do
      controller.get_return_to_path.should be_nil
    end

    context 'contest referer' do
      it 'returns nil if the referer is not the contests_path' do
        request.env["HTTP_REFERER"] = 'http://test.com/not_contests'
        controller.get_return_to_path.should be_nil
      end

      it 'returns the contests path if the referer is the contests_path' do
        request.env["HTTP_REFERER"] = 'http://test.com/contests'
        controller.get_return_to_path.should == contests_path
      end

      it 'returns the specific contest if the referer has a contest id' do
        request.env["HTTP_REFERER"] = 'http://test.com/contests/1'
        controller.get_return_to_path.should == contest_path(1)
      end
    end
  end

  describe '#contest_notification_for_user' do
    let(:presenter_stub) {
      {template: 'stuff', data: {'other_stuff' => true}}
    }

    it 'does not show a notification to white-list users' do
      controller.stub(:current_virtual_currency).and_return(double(subdomain: 'random'))

      get :index

      assigns(:notification).should be_nil
    end

    it 'sets the notification if the user should see one' do
      controller.stub(:current_user).and_return(double(id: 1, logged_in?: true))
      controller.stub(:current_virtual_currency).and_return(double(subdomain: 'www'))
      controller.stub(:contest_cookie_present?).and_return(false)
      ContestNotificationPresenter.stub(:for_user).and_return(presenter_stub)

      get :index

      assigns(:notification).should == presenter_stub.stringify_keys
    end

    it 'does not show a notification if there is not a user logged in' do
      get :index

      assigns(:notification).should be_nil
    end
  end
end
