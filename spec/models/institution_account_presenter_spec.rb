require 'spec_helper'

describe InstitutionAccountPresenter do
  let(:intuit_account_response) do
    {:account_id=>"400006583998",
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
    :current_balance=>"-1029.05"}
  end

  subject(:institution_account) { InstitutionAccountPresenter.new(intuit_account_response) }

  describe 'initialize' do
    it 'returns the account id in intuit' do
      institution_account.account_id.should == '400006583998'
    end

    it 'returns the account status' do
      institution_account.active.should == true
    end

    it 'returns the display position' do
      institution_account.display_position.should == 4
    end

    it 'returns the account name' do
      institution_account.name.should == 'My Line of Credit'
    end
  end

  describe '#masked_account_number' do
    it 'returns the masked account number' do
      institution_account.masked_account_number.should == '****-****-****-6666'
    end
  end

  describe '#to_hash' do
    it 'returns a hash representing the account' do
      institution_account.to_hash.should == {
        account_id: '400006583998',
        account_number: '****-****-****-6666',
        active: true,
        display_position: 4,
        name: 'My Line of Credit'
      }
    end
  end
end
