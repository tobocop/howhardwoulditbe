require 'spec_helper'

describe ApplicationController do
  describe '#sign_in_user' do
    let(:user) { mock_model(Plink::User, id: 123, password_hash: 'hashypassy') }

    it 'sets current_user_id in the session' do
      controller.sign_in_user(user)
      session[:current_user_id].should == 123
    end

    it 'sets the plinkUID cookie for coldfusion to the base64 encoded version of the hashed password' do
      controller.sign_in_user(user)
      cookies[:PLINKUID].should == "aGFzaHlwYXNzeQ==\n"
    end
  end

  describe '#current_user' do
    it 'returns the current user' do
      session[:current_user_id] = 3
      user = stub
      user_presenter = stub
      UserPresenter.stub(:new).with(user: user) { user_presenter }
      Plink::User.should_receive(:find).with(3) { user }

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
      ActiveIntuitAccount.stub(:user_has_account?).with(1) { false }
      expect { controller.user_must_be_linked }.to raise_error(Exception, 'User account must be linked')
    end

    it 'returns nil if the user is linked' do
      ActiveIntuitAccount.stub(:user_has_account?).with(1) { true }
      controller.user_must_be_linked.should be_nil
    end
  end
end