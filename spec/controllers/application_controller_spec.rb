require 'spec_helper'

describe ApplicationController do
  describe '#sign_in_user' do
    it 'sets the current_user_id cookie' do
      user = mock_model(User, id: 123)
      controller.sign_in_user(user)
      session[:current_user_id].should == 123
    end
  end

  describe '#current_user' do
    it 'returns the current user' do
      session[:current_user_id] = 3
      user = stub
      User.should_receive(:find).with(3) { user }

      controller.current_user.should == user
    end
  end

  describe '#current_virtual_currency' do
    it 'returns the correct virtual currency' do
      currency = create_virtual_currency(name: 'Plonk Points')
      current_user = create_user
      current_user.primary_virtual_currency = currency
      current_user.save!

      session[:current_user_id] = current_user.id

      presented_currency = controller.current_virtual_currency

      presented_currency.currency_name.should == 'Plonk Points'
      presented_currency.user_balance_currency.should == '0'
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
      controller.stub(:current_user) { true }
      controller.user_logged_in?.should == true

    end

    it 'it returns false if there is no current user' do
      controller.stub(:current_user) { nil }
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
end