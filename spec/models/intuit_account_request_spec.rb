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

  let(:intuit_transaction_response) do
    {:status_code=>"200",
     :result=>
      {:transaction_list=>
        {:not_refreshed_reason=>"NOT_NECESSARY",
         :banking_transaction=>
          [{:id=>"400677837558",
            :currency_type=>"USD",
            :institution_transaction_id=>"INTUIT-400677837558",
            :payee_name=>"CHECKING credit 19",
            :posted_date=>"2014-01-19T00:00:00-08:00",
            :user_date=>"2014-01-19T00:00:00-08:00",
            :amount=>"1.19",
            :pending=>"false",
            :categorization=>{:common=>nil}},
           {:id=>"400677837559",
            :currency_type=>"USD",
            :institution_transaction_id=>"INTUIT-400677837559",
            :payee_name=>"CHECKING credit 15",
            :posted_date=>"2014-01-15T00:00:00-08:00",
            :user_date=>"2014-01-15T00:00:00-08:00",
            :amount=>"1.15",
            :pending=>"false",
            :categorization=>{:common=>nil}
          }]
        }
      }
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

  let(:intuit_account_request_record) { double(Plink::IntuitRequestRecord, update_attributes: true) }

  before do
    Plink::IntuitRequestRecord.stub(:find).and_return(intuit_account_request_record)
    Intuit::Request.stub(:new).and_return(intuit_request)
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

  describe '#authenticate' do
    before do
      intuit_request.stub(:accounts).and_return(intuit_response)
      intuit_request.stub(:login_accounts).and_return(intuit_login_accounts_response)

      ENCRYPTION.stub(:decrypt_and_verify).and_return(['default', 'yup'])
      ENCRYPTION.stub(:encrypt_and_sign).and_return('response')
    end

    it "decrypts the credentials" do
      ENCRYPTION.should_receive(:decrypt_and_verify).with('user_and_pw')

      request.authenticate('user_and_pw')
    end

    it "makes a call to get the user's accounts from Intuit" do
      Plink::IntuitRequestRecord.stub(:find).and_return(double(update_attributes: true))

      intuit_request.should_receive(:accounts).and_return(intuit_response)

      request.authenticate('user_and_pw')
    end

    it 'updates the request record' do
      intuit_account_request_record.should_receive(:update_attributes).
        with({processed: true, response: 'response'}).and_return(true)

      request.authenticate('user_and_pw')
    end

    context 'with a successful response from Intuit' do
      it 'calls getLoginAccounts' do
        Plink::IntuitRequestRecord.stub(:find).and_return(double(update_attributes: true))

        intuit_request.should_receive(:login_accounts).with('128700189').and_return(intuit_response)

        request.authenticate('user_and_pw')
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

        request.authenticate('user_and_pw')
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

        request.authenticate('user_and_pw')
      end
    end

    it 'does not call getLoginAccounts if the response is an MFA' do
      intuit_request.stub(:accounts).and_return(intuit_mfa_response)

      intuit_request.should_not_receive(:login_accounts)

      request.authenticate('user_and_pw')
    end

    context 'with a failed response from intuit' do
      let(:login_account_aggregation_error) do
        intuit_response[:status_code] = '200'
        intuit_response[:result][:account_list][:credit_account].first[:aggr_status_code] = '1'
        intuit_response
      end
      it 'does not call getLoginAccounts on an account error' do
        intuit_request.stub(:accounts).and_return(intuit_error_response)

        intuit_request.should_not_receive(:login_accounts)

        request.authenticate('user_and_pw')
      end

      context 'for an aggregation error' do
        it 'returns an error object' do
          intuit_request.stub(:login_accounts).and_return(login_account_aggregation_error)

          expect { request.authenticate('user_and_pw') }.to_not raise_error
        end
      end
    end
  end

  describe '#respond_to_mfa' do
    before do
      intuit_request.stub(:respond_to_mfa).and_return(intuit_mfa_response)
      ENCRYPTION.stub(:decrypt_and_verify).and_return('one')
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
        Plink::IntuitRequestRecord.stub(:find).and_return(double(update_attributes: true))

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

  describe '#select_account!' do
    let(:staged_account) do
      mock_model(Plink::UsersInstitutionAccountStagingRecord,
        account_id: '3456',
        values_for_final_account: { stuff: 'yup' },
        update_attributes: true
      )
    end
    let(:users_institution_account_record) do
      mock_model(Plink::UsersInstitutionAccountRecord,
        account_id: '133713371337',
        account_number: 2,
        account_number_last_four: '1234',
        bank_name: 'rich people bank',
        incomplete_reverification_id: nil,
        name: 'Rich people account',
        requires_reverification?: false,
        update_attributes: true,
        users_institution_id: 4657
      )
    end
    let(:parsed_response) do
      {
        error: false,
        value: {
          account_name: 'Rich people account',
          updated_accounts: 0
        }
      }.to_json
    end
    let(:intuit_request) { double(Intuit::Request, update_account_type: nil, get_transactions: intuit_transaction_response) }

    before do
      Plink::UsersInstitutionAccountStagingRecord.stub(:find).and_return(staged_account)
      Plink::UsersInstitutionAccountRecord.stub(:create).
        and_return(users_institution_account_record)
    end

    subject(:intuit_update) { IntuitAccountRequest.new(109, 342, nil, nil, nil) }

    it 'creates a Plink::UsersInstitutionAccountRecord' do
      Plink::UsersInstitutionAccountRecord.should_receive(:create).with(stuff: 'yup')

      intuit_update.select_account!(staged_account, nil, [])
    end

    it 'updates the request record' do
      ENCRYPTION.stub(:encrypt_and_sign).and_return('so update')

      intuit_account_request_record.should_receive(:update_attributes).
        with({processed: true, response: 'so update'}).and_return(true)

      intuit_update.select_account!(staged_account, nil, [])
    end

    context 'with an account type set' do
      it 'updates the users institution account staging record' do
        staged_account.should_receive(:update_attributes).with(account_type: 'CREDITCARD')

        intuit_update.select_account!(staged_account, 'credit', [])
      end

      it 'updates the users institution account record' do
        users_institution_account_record.should_receive(:update_attributes).
          with(account_type: 'CHECKING')

        intuit_update.select_account!(staged_account, 'debit', [])
      end

      it 'calls to intuit to update the account type' do
        intuit_request.should_receive(:update_account_type).with('133713371337', 'CHECKING')

        intuit_update.select_account!(staged_account, 'debit', [])
      end
    end

    context 'with accounts to end date' do
      let(:staging_records) { double }

      it 'sets the end date for all accounts' do
        Plink::UsersInstitutionAccountRecord.should_receive(:where).
          with(usersInstitutionAccountID: [1,2,3]).and_return(staging_records)
        staging_records.should_receive(:update_all).with(endDate: Date.current)

        intuit_update.select_account!(staged_account, 'debit', [1,2,3])
      end
    end
  end
end
