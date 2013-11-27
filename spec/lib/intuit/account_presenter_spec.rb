require 'spec_helper'

describe Intuit::AccountPresenter do
  let(:intuit_account_response) do
    {
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
    }
  end

  subject(:institution_account) { Intuit::AccountPresenter.new(intuit_account_response, :credit_account) }

  describe 'initialize' do
    it 'returns the aggr_attempt_date' do
      institution_account.aggr_attempt_date.should == '2013-10-29T21:05:53.029-07:00'
    end

    it 'returns the aggr_status_code' do
      institution_account.aggr_status_code.should == '0'
    end

    it 'returns the aggr_success_date' do
      institution_account.aggr_success_date.should == '2013-10-29T21:05:53.029-07:00'
    end

    it 'returns the currency_code' do
      institution_account.currency_code.should == 'INR'
    end

    it 'returns the display position' do
      institution_account.display_position.should == 4
    end

    it 'returns the account id in intuit' do
      institution_account.id.should == '400006583998'
    end

    it 'returns the account name' do
      institution_account.name.should == 'My Line of Credit'
    end

    it 'returns the login id' do
      institution_account.login_id.should == '128700189'
    end

    it 'returns the account status' do
      institution_account.status.should == 'ACTIVE'
    end

    it 'returns the type' do
      institution_account.type.should == 'creditAccount'
    end

    it 'returns the type_description' do
      institution_account.type_description.should == 'LINEOFCREDIT'
    end
  end

  describe '#to_hash' do
    it 'returns a hash representing the account' do
      institution_account.to_hash.should == {
        aggr_attempt_date: '2013-10-29T21:05:53.029-07:00',
        aggr_status_code: '0',
        aggr_success_date: '2013-10-29T21:05:53.029-07:00',
        currency_code: 'INR',
        display_position: 4,
        id: '400006583998',
        login_id: '128700189',
        name: 'My Line of Credit',
        number: '****-****-****-6666',
        number_hash: Digest::SHA512.hexdigest('8000006666'),
        number_last_four: '6666',
        status: 'ACTIVE',
        type: 'creditAccount',
        type_description: 'LINEOFCREDIT'
      }
    end
  end
end
