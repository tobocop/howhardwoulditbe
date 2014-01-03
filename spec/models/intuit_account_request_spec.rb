require 'spec_helper'

describe IntuitAccountRequest do
  let(:params) {
    {
      hash_check: 'randomhashofstuff',
      institution_id: 4,
      intuit_institution_id: 908,
      request_id: 1,
      user_id: 123
    }
  }

  let(:intuit_response) do
    {
      status_code: '201',
      result: {
        account_list: {
          credit_account: [{
            :account_id=>"400006583998",
            :status=>"ACTIVE",
            :account_number=>"8000006666",
            :account_nickname=>"My Line of Credit",
            :display_position=>"4",
            :institution_id=>"100000",
            :balance_date=>"2013-10-29T00:00:00-07:00",
            :aggr_success_date=>"2013-10-29T21:05:53.029-07:00",
            :aggr_attempt_date=>"2013-10-29T21:05:53.029-07:00",
            :aggr_status_code=>"0",
            :currency_code=>"INR",
            :institution_login_id=>"128700189",
            :credit_account_type=>"LINEOFCREDIT",
            :current_balance=>"-1029.05"
          }]
        }
      }
    }
  end

  let(:intuit_login_accounts_response) do
    intuit_response[:status_code] = '200'
    intuit_response
  end

  let(:intuit_mfa_response) do
    { :status_code=>"401",
      :result=>{
        :challenges=>{
          :challenge=>[
            {:text=>"Enter your first pet's name:"},
            {:text=>"Enter your high school's name:"}
          ]
        }
      },
      :challenge_session_id=>"26b5edd2-2dff-4225-8b39-ac36a19ba789",
      :challenge_node_id=>"10.136.17.82"
    }
  end

  let(:intuit_error_response) do
    { :status_code=>"106",
      :result=>{
        :status=>{
          :error_info=>{
            :error_message=>'you dumb'
          }
        }
      }
    }
  end

  let(:intuit_request) { double(Intuit::Request) }

  let(:request) do
    args = [ params[:user_id], params[:institution_id], params[:intuit_institution_id], params[:request_id], params[:hash_check] ]
    IntuitAccountRequest.new(*args)
  end

  describe 'initialize' do
    it 'sets the user_id' do
      request.user_id.should == 123
    end

    it 'sets the institution_id' do
      request.institution_id.should == 4
    end

    it 'sets the intuit_institution_id' do
      request.intuit_institution_id.should == 908
    end

    it 'sets the request id' do
      request.request_id.should == 1
    end

    it 'sets the hash_check' do
      request.hash_check.should == 'randomhashofstuff'
    end
  end

  describe '#accounts' do
    let(:intuit_account_request_record) { double(Plink::IntuitAccountRequestRecord, update_attributes: true) }

    before do
      Intuit::Request.stub(:new).and_return(intuit_request)
      intuit_request.stub(:accounts).and_return(intuit_response)
      intuit_request.stub(:login_accounts).and_return(intuit_login_accounts_response)

      ENCRYPTION.stub(:decrypt_and_verify).and_return(['default', 'yup'])
      ENCRYPTION.stub(:encrypt_and_sign).and_return('response')

      Plink::IntuitAccountRequestRecord.stub(:find).and_return(intuit_account_request_record)
    end

    it "decrypts the credentials" do
      ENCRYPTION.unstub(:decrypt_and_verify)
      ENCRYPTION.should_receive(:decrypt_and_verify).with('user_and_pw')

      request.accounts('user_and_pw')
    end

    it "makes a call to get the user's accounts from Intuit" do
      Plink::IntuitAccountRequestRecord.stub(:find).and_return(double(update_attributes: true))

      intuit_request.should_receive(:accounts).and_return(intuit_response)

      request.accounts('user_and_pw')
    end

    it 'updates the request record' do
      intuit_account_request_record.should_receive(:update_attributes).
        with({processed: true, response: 'response'}).and_return(true)

      request.accounts('user_and_pw')
    end

    context 'with a successful response from Intuit' do
      it 'calls getLoginAccounts' do
        Plink::IntuitAccountRequestRecord.stub(:find).and_return(double(update_attributes: true))

        intuit_request.should_receive(:login_accounts).with('128700189').and_return(intuit_response)

        request.accounts('user_and_pw')
      end

      it 'creates a Plink::UsersInstitutionRecord' do
        expected_params = {
          hash_check: 'randomhashofstuff',
          is_active: true,
          institution_id: 4,
          intuit_institution_login_id: '128700189',
          user_id: 123
        }

        Plink::UsersInstitutionRecord.should_receive(:create).
          with(expected_params).
          and_return(double(id: 5))

        request.accounts('user_and_pw')
      end

      it 'creates Plink::UsersInstitutionAccountStaging records' do
        Plink::UsersInstitutionRecord.stub(:create).and_return(double(id: 5))

        staging_attrs = {
          account_id: '400006583998',
          account_number_hash: Digest::SHA512.hexdigest('8000006666'),
          account_number_last_four: '6666',
          account_type: 'creditAccount',
          account_type_description: 'LINEOFCREDIT',
          aggr_attempt_date: '2013-10-29T21:05:53.029-07:00',
          aggr_status_code: '0',
          aggr_success_date: '2013-10-29T21:05:53.029-07:00',
          currency_code: 'INR',
          in_intuit: true,
          name: 'My Line of Credit',
          status: 'ACTIVE',
          user_id: 123,
          users_institution_id: 5
        }

        Plink::UsersInstitutionAccountStagingRecord.should_receive(:create).
          with(staging_attrs)

        request.accounts('user_and_pw')
      end
    end

    it 'does not call getLoginAccounts if the response is an MFA' do
      intuit_request.stub(:accounts).and_return(intuit_mfa_response)

      intuit_request.should_not_receive(:login_accounts)

      request.accounts('user_and_pw')
    end

    it 'does not call getLoginAccounts if the response is an error' do
      intuit_request.stub(:accounts).and_return(intuit_error_response)

      intuit_request.should_not_receive(:login_accounts)

      request.accounts('user_and_pw')
    end
  end

  describe '#respond_to_mfa' do
    let(:intuit_account_request_record) { double(Plink::IntuitAccountRequestRecord, update_attributes: true) }

    before do
      Intuit::Request.stub(:new).and_return(intuit_request)
      intuit_request.stub(:respond_to_mfa).and_return(intuit_mfa_response)
      ENCRYPTION.stub(:decrypt_and_verify).and_return('one')
      Plink::IntuitAccountRequestRecord.stub(:find).and_return(intuit_account_request_record)
    end

    it 'updates the request record' do
      ENCRYPTION.stub(:encrypt_and_sign).and_return('encrypted_response')

      intuit_account_request_record.should_receive(:update_attributes).
        with({processed: true, response: 'encrypted_response'}).and_return(true)

      request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
    end

    it 'calls out to intuit' do
      intuit_request.should_receive(:respond_to_mfa).and_return(intuit_mfa_response)

      request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
    end

    context 'with a successful response from Intuit' do
      before do
        intuit_request.stub(:respond_to_mfa).and_return(intuit_response)
        intuit_request.stub(:login_accounts).and_return(intuit_login_accounts_response)
      end

      it 'calls getLoginAccounts' do
        Plink::IntuitAccountRequestRecord.stub(:find).and_return(double(update_attributes: true))

        intuit_request.should_receive(:login_accounts).with('128700189').and_return(intuit_response)

        request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
      end

      it 'creates a Plink::UsersInstitutionRecord' do
        expected_params = {
          hash_check: 'randomhashofstuff',
          is_active: true,
          institution_id: 4,
          intuit_institution_login_id: '128700189',
          user_id: 123
        }

        Plink::UsersInstitutionRecord.should_receive(:create).
          with(expected_params).
          and_return(double(id: 5))

        request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
      end

      it 'creates Plink::UsersInstitutionAccountStaging records' do
        Plink::UsersInstitutionRecord.stub(:create).and_return(double(id: 5))

        staging_attrs = {
          account_id: '400006583998',
          account_number_hash: Digest::SHA512.hexdigest('8000006666'),
          account_number_last_four: '6666',
          account_type: 'creditAccount',
          account_type_description: 'LINEOFCREDIT',
          aggr_attempt_date: '2013-10-29T21:05:53.029-07:00',
          aggr_status_code: '0',
          aggr_success_date: '2013-10-29T21:05:53.029-07:00',
          currency_code: 'INR',
          in_intuit: true,
          name: 'My Line of Credit',
          status: 'ACTIVE',
          user_id: 123,
          users_institution_id: 5
        }

        Plink::UsersInstitutionAccountStagingRecord.should_receive(:create).
          with(staging_attrs)

        request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
      end
    end
  end
end
