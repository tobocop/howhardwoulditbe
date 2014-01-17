require 'spec_helper'

describe Intuit::Request do
  let(:aggcat) { double(Aggcat) }
  let(:logger) { double(:logger, log_and_return_response: true) }

  before do
    Aggcat.stub(:scope).and_return(aggcat)
    Intuit::Logger.stub(:new).and_return(logger)
  end

  describe '#new' do
    it 'instantiates Aggcat' do
      Aggcat.should_receive(:scope).with(123)

      Intuit::Request.new(123)
    end
  end

  describe '#accounts' do
    it 'calls discoverAndAddAccounts [POST "/institutions/#{institution_id}/logins"]' do
      aggcat.should_receive(:discover_and_add_accounts).with(456, 'user', 'password')

      Intuit::Request.new(123).accounts(456, ['user', 'password'])
    end

    it 'logs the response' do
      aggcat.stub(:discover_and_add_accounts).and_return('so doge')

      method_and_params = {method: :discover_and_add_accounts, params: {intuit_institution_id: 456}}
      logger.should_receive(:log_and_return_response).with('so doge', 123, method_and_params)

      Intuit::Request.new(123).accounts(456, ['user', 'password'])
    end
  end

  describe '#account' do
    it 'calls getAccount [GET "/accounts/#{account_id}"]' do
      aggcat.should_receive(:account).with(12345)

      Intuit::Request.new(123).account(12345)
    end

    it 'logs the response' do
      aggcat.stub(:account).and_return('so doge')

      method_and_params = {method: :account, params: {account_id: 12345}}
      logger.should_receive(:log_and_return_response).with('so doge', 123, method_and_params)

      Intuit::Request.new(123).account(12345)
    end
  end

  describe '#respond_to_mfa' do
    it 'calls discoverAndAddAccounts [POST "/institutions/#{institution_id}/logins"]' do
      aggcat.should_receive(:account_confirmation).with(456, 1, 2, 'my answer')

      Intuit::Request.new(123).respond_to_mfa(456, 1, 2, 'my answer')
    end

    it 'logs the response' do
      aggcat.stub(:account_confirmation).and_return('so doge')

      method_and_params = {method: :account_confirmation, params: {challenge_session_id: 1, challenge_node_id: 2}}
      logger.should_receive(:log_and_return_response).with('so doge', 123, method_and_params)

      Intuit::Request.new(123).respond_to_mfa(456, 1, 2, 'my answer')
    end
  end

  describe '#update_credentials' do
    before { aggcat.stub(:update_login).and_return(true) }

    it 'calls [PUT "logins/#{login_id}?refresh=true"]' do
      aggcat.should_receive(:update_login).with(456, 1, 'user', 'password')

      Intuit::Request.new(123).update_credentials(456, 1, ['user', 'password'])
    end

    it 'logs the response' do
      aggcat.stub(:update_login).and_return('so doge')

      method_and_params = {method: :update_login, params: {intuit_institution_id: 456, login_id: 1}}
      logger.should_receive(:log_and_return_response).with('so doge', 123, method_and_params)

      Intuit::Request.new(123).update_credentials(456, 1, ['user', 'password'])
    end
  end

  describe '#update_mfa' do
    before { aggcat.stub(:update_login_confirmation).and_return(true) }

    it 'calls [PUT "logins/#{login_id}?refresh=true"]' do
      aggcat.should_receive(:update_login_confirmation).with(456, 1, 2, 'my answer')

      Intuit::Request.new(123).update_mfa(456, 1, 2, 'my answer')
    end

    it 'logs the response' do
      aggcat.stub(:update_login_confirmation).and_return('so doge')

      method_and_params = {method: :update_login_confirmation, params: {challenge_session_id: 1, challenge_node_id: 2, login_id: 456}}
      logger.should_receive(:log_and_return_response).with('so doge', 123, method_and_params)

      Intuit::Request.new(123).update_mfa(456, 1, 2, 'my answer')
    end
  end

  describe '#login_accounts' do
    it 'calls getLoginAccounts [GET "/logins/#{login_id}/accounts"]' do
      aggcat.should_receive(:login_accounts).with('1234123412341234')

      Intuit::Request.new(123).login_accounts('1234123412341234')
    end

    it 'logs the response' do
      aggcat.stub(:login_accounts).and_return('so doge')

      method_and_params = {method: :login_accounts, params: {login_id: "1234123412341234"}}
      logger.should_receive(:log_and_return_response).with('so doge', 123, method_and_params)

      Intuit::Request.new(123).login_accounts('1234123412341234')
    end
  end

  describe '#institution_data' do
    it 'calls getInstitutionDetails [GET "/institutions/#{institution_id}"]' do
      aggcat.should_receive(:institution).with('ABCD')

      Intuit::Request.new(123).institution_data('ABCD')
    end

    it 'logs the response' do
      aggcat.stub(:institution).and_return('so doge')

      method_and_params = {method: :institution, params: {intuit_institution_id: "ABCD"}}
      logger.should_receive(:log_and_return_response).with('so doge', 1, method_and_params)

      Intuit::Request.new(1).institution_data('ABCD')
    end
  end

  describe '#update_account_type' do
    it 'calls updateAccountType [PUT "/accounts/#{account_id}"]' do
      aggcat.should_receive(:update_account_type).with(1234567, 'BEST ACCOUNT TYPE')

      Intuit::Request.new(123).update_account_type(1234567, 'BEST ACCOUNT TYPE')
    end

    it 'logs the response' do
      aggcat.stub(:update_account_type).and_return('so doge')

      method_and_params = {method: :update_account_type, params: {account_id: 1234567, account_type: 'BEST ACCOUNT TYPE'}}
      logger.should_receive(:log_and_return_response).with('so doge', 1, method_and_params)

      Intuit::Request.new(1).update_account_type(1234567, 'BEST ACCOUNT TYPE')
    end
  end
end
