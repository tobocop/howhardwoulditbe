require 'spec_helper'

describe Intuit::Response do
  describe '.new' do
    it 'sets the raw response from intuit' do
      intuit_response = {status_code: '201', result: 'the best'}

      response = Intuit::Response.new(intuit_response)

      response.raw_response[:status_code].should == '201'
      response.raw_response[:result].should == 'the best'
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
  end
end