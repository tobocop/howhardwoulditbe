require 'spec_helper'

describe IntuitAccountRequest do
  let(:params) {
    {
      user_id: 123,
      intuit_institution_id: 908,
      request_id: 1,
      user_and_password: 'encryptedstring'
    }
  }

  let(:request) do
    args = [params[:user_id], params[:user_and_password], params[:intuit_institution_id], params[:request_id]]
    IntuitAccountRequest.new(*args)
  end

  describe 'initialize' do
    it 'sets the user_id' do
      request.user_id.should == 123
    end

    it 'sets the intuit_institution_id' do
      request.intuit_institution_id.should == 908
    end

    it 'sets the request id' do
      request.request_id.should == 1
    end

    it 'set the user and password' do
      request.user_and_password.should == 'encryptedstring'
    end
  end

  describe '#accounts' do
    let(:aggcat) {
      mock(Aggcat, discover_and_add_accounts: {
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
      })
    }

    let(:intuit_account_request_record) do
      mock(Plink::IntuitAccountRequestRecord, update_attributes: true)
    end

    before do
      ENCRYPTION.stub(:decrypt_and_verify).and_return(['default', 'yup'])
      ENCRYPTION.stub(:encrypt_and_sign).and_return('response')
      Aggcat.stub(:scope).with(123).and_return(aggcat)
      Plink::IntuitAccountRequestRecord.stub(:find).and_return(intuit_account_request_record)
    end

    it "decrypts the credentials" do
      ENCRYPTION.unstub(:decrypt_and_verify)
      ENCRYPTION.should_receive(:decrypt_and_verify).with('encryptedstring')

      request.accounts
    end

    it 'updates the request record with the intuit response' do
      intuit_account_request_record.should_receive(:update_attributes).
        with({processed: true, response: 'response'}).and_return(true)

      request.accounts
    end

    it 'makes a call to intuit' do
      Plink::IntuitAccountRequestRecord.stub(:find).and_return(double(update_attributes: true))

      request.accounts
    end
  end
end
