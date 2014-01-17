require 'spec_helper'

describe IntuitUpdate do
  describe '#select_acount!' do
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
        account_name: 'Rich people account',
        account_number: 2,
        account_number_last_four: '1234',
        bank_name: 'rich people bank',
        requires_reverification?: false,
        incomplete_reverification_id: nil,
        users_institution_id: 4657,
        update_attributes: true
      )
    end
    let(:intuit_request) { double(Intuit::Request, update_account_type: true) }

    before do
      Plink::UsersInstitutionAccountRecord.stub(:create).
        and_return(users_institution_account_record)
      Intuit::Request.stub(:new).and_return(intuit_request)
    end

    subject(:intuit_update) { IntuitUpdate.new(109) }

    it 'creates a Plink::UsersInstitutionAccountRecord' do
      Plink::UsersInstitutionAccountRecord.should_receive(:create).with(stuff: 'yup')

      intuit_update.select_account!(staged_account, nil)
    end

    context 'with an account type set' do
      it 'updates the users institution account staging record' do
        staged_account.should_receive(:update_attributes).with(account_type: 'CREDITCARD')

        intuit_update.select_account!(staged_account, 'credit')
      end

      it 'updates the users institution account record' do
        users_institution_account_record.should_receive(:update_attributes).
          with(account_type: 'CHECKING')

        intuit_update.select_account!(staged_account, 'debit')
      end

      it 'calls to intuit to update the account type' do
        intuit_request.should_receive(:update_account_type).with('133713371337', 'CHECKING')

        intuit_update.select_account!(staged_account, 'debit')
      end
    end
  end
end
