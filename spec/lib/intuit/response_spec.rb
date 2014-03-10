require 'spec_helper'

describe Intuit::Response do
  let(:successful_intuit_response) {
    {
      status_code: '201',
      result: {
        account_list: {
          banking_account: [
            {institution_login_id: 123, account_number: '1233412345', aggr_status_code: 0},
            {institution_login_id: 456, account_number: '1233412345', aggr_status_code: 0}
          ]
        }
      }
    }
  }
  let(:aggregation_error_intuit_response) {
    {
      status_code: '201',
      result: {
        account_list: {
          banking_account: [
            {institution_login_id: 123, account_number: '1233412345', aggr_status_code: 3},
            {institution_login_id: 456, account_number: '1233412345', aggr_status_code: 0}
          ]
        }
      }
    }
  }
  let(:all_accounts_aggregation_error_intuit_response) {
    {
      status_code: '201',
      result: {
        account_list: {
          banking_account: [
            {institution_login_id: 123, account_number: '1233412345', aggr_status_code: 4},
            {institution_login_id: 456, account_number: '1233412345', aggr_status_code: 3}
          ]
        }
      }
    }
  }

  describe '.new' do
    it 'sets the raw response from intuit' do
      intuit_response = {status_code: '201', result: 'the best'}

      response = Intuit::Response.new(intuit_response)

      response.raw_response[:status_code].should == '201'
      response.raw_response[:result].should == 'the best'
    end
  end

  describe '#accounts?' do
    it 'returns true if there is the account_list field in the result' do
      intuit_response = {status_code: '201', result: {account_list: {}}}
      response = Intuit::Response.new(intuit_response)

      response.accounts?.should be_true
    end

    it 'returns false if there is not an account_list' do
      intuit_response = {status_code: '261', result: {}}
      response = Intuit::Response.new(intuit_response)

      response.accounts?.should be_false
    end

    it 'returns false if the result key is a blank string' do
      intuit_response = {status_code: '261', result: ''}
      response = Intuit::Response.new(intuit_response)

      response.accounts?.should be_false
    end
  end

  describe '#login_id' do
    it 'returns the login_id of the first account in the account list' do
      response = Intuit::Response.new(successful_intuit_response)

      response.login_id.should == 123
    end
  end

  describe '#aggregation_error?' do
    it 'returns false if at least one of the aggregation status codes in the account list are 0' do
      response = Intuit::Response.new(aggregation_error_intuit_response)

      response.aggregation_error?.should be_false
    end

    it 'returns false if there are no accounts' do
      response = Intuit::Response.new(successful_intuit_response[:result].delete(:account_list))

      response.aggregation_error?.should be_false
    end

    it 'returns true if there are only non-zero aggregation status code in the account list' do
      response = Intuit::Response.new(all_accounts_aggregation_error_intuit_response)

      response.aggregation_error?.should be_true
    end
  end

  describe '#first_error_status_code' do
    it 'returns the first non-zero aggregation status code in the account list' do
      response = Intuit::Response.new(aggregation_error_intuit_response)

      response.first_error_status_code.should == 3
    end
  end

  describe '#accounts' do
    it 'returns a list of accounts' do
      account = {
        account_id: 1,
        account_nickname: 'namey',
        account_number: '1233412345',
        banking_account_type: 'Best account evar',
        aggr_attempt_date: 'some_date_and_time',
        aggr_status_code: 0,
        aggr_success_date: 'some_date_and_time',
        currency_code: 'INR',
        display_position: 0,
        institution_login_id: 123,
        status: 'ACTIVE'
      }
      intuit_response = {status_code: '201', result: {account_list: {banking_account: [account]}}}

      response = Intuit::Response.new(intuit_response)

      account_hash = {
        id: 1,
        number: '****-****-****-2345',
        number_hash: Digest::SHA512.hexdigest('1233412345'),
        number_last_four: '2345',
        type: "bankingAccount",
        type_description: 'Best account evar',
        aggr_attempt_date: 'some_date_and_time',
        aggr_status_code: 0,
        aggr_success_date: 'some_date_and_time',
        currency_code: 'INR',
        display_position: 0,
        login_id: 123,
        name: 'namey',
        status: 'ACTIVE'
      }
      response.accounts.should == [account_hash]
    end
  end

  describe '#parse' do
    context 'with a 200 or 201 status code' do
      it 'does not return an error or mfa if the status code is 200' do
        intuit_response = {status_code: '200', result: {account_list: {}}}
        response = Intuit::Response.new(intuit_response).parse

        response[:error].should be_false
        response[:mfa].should be_false
      end

      it 'does not return an error or mfa if the status code is 201' do
        intuit_response = {status_code: '201', result: {account_list: {}}}
        response = Intuit::Response.new(intuit_response).parse

        response[:error].should be_false
        response[:mfa].should be_false
      end

      it 'returns a list of accounts when present' do
        account = {
          account_id: 1,
          account_nickname: 'namey',
          account_number: '1233412345',
          banking_account_type: 'Best account evar',
          aggr_attempt_date: 'some_date_and_time',
          aggr_status_code: 0,
          aggr_success_date: 'some_date_and_time',
          currency_code: 'INR',
          display_position: 0,
          institution_login_id: 123,
          status: 'ACTIVE'
        }
        intuit_response = {status_code: '201', result: {account_list: {banking_account: [account]}}}

        response = Intuit::Response.new(intuit_response).parse

        account_hash = {
          id: 1,
          number: '****-****-****-2345',
          number_hash: Digest::SHA512.hexdigest('1233412345'),
          number_last_four: '2345',
          type: "bankingAccount",
          type_description: 'Best account evar',
          aggr_attempt_date: 'some_date_and_time',
          aggr_status_code: 0,
          aggr_success_date: 'some_date_and_time',
          currency_code: 'INR',
          display_position: 0,
          login_id: 123,
          name: 'namey',
          status: 'ACTIVE'
        }
        response[:value].should == [account_hash]
      end

      it 'does not return an error when the response is successful, but has no account list and does not need to have transactions' do
        intuit_response = {status_code: '200', result: ''}

        response = Intuit::Response.new(intuit_response)

        response.parse.should == {error: false}
      end

      it 'indicates if the request included transactions if it did not have an account list' do
        intuit_response = {status_code: '200', result: {transaction_list: {credit_card_transaction: true}}}

        response = Intuit::Response.new(intuit_response)

        response.parse.should == {error: false, transactions: true}
      end

      it 'indicates an error if transactions are included and the list is blank' do
        intuit_response = {:status_code => '200', :result => {:transaction_list=>{:not_refreshed_reason=>'NOT_NECESSARY'}}}

        response = Intuit::Response.new(intuit_response)

        response.parse.should == {error: true, value: 'Account has no transactions.'}
      end
    end

    context 'with a 401 status code' do
      let(:intuit_response) { {status_code: '401', result: {challenges: {challenge: 'stuff'}}} }

      it 'returns mfa' do
        response = Intuit::Response.new(intuit_response).parse

        response[:error].should be_false
        response[:mfa].should be_true
      end

      it 'returns the mfa questions' do
        response = Intuit::Response.new(intuit_response).parse

        response[:value][:questions].should == 'stuff'
      end
    end

    context 'with an error code (e.g. not 200, 201, 401)' do
      let(:intuit_response) do
        {status_code: '300', result: {status: {error_info: {error_message: "It's broken"}}}}
      end

      it 'returns an error' do
        response = Intuit::Response.new(intuit_response).parse

        response[:error].should be_true
      end

      it 'returns the error messaging provided by intuit' do
        response = Intuit::Response.new(intuit_response).parse

        response[:value].should == "It's broken"
      end
    end

    context 'with an error that does not have error info' do
      let(:intuit_response) do
        {status_code: '404', result:{}}
      end

      it 'returns an error with a generic message' do
        response = Intuit::Response.new(intuit_response).parse

        response[:error].should be_true
        response[:value].should == 'We could not determine the nature of the error.'
      end
    end
  end
end
