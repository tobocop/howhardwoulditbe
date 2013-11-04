require 'spec_helper'

describe 'intuit:remove_accounts' do
  include_context 'rake'

  let(:successful_delete_response) { {status_code: '200', result: ''} }
  let(:not_found_delete_response) {
    {
      status_code: '404',
      result: {
        status: {
          error_info: {
            error_type: 'APP_ERROR',
            error_code: 'api.database.account.notfound',
            error_message: 'internal api error while processing the request',
            correlation_id: 'gw-62a53b45-157a-490e-812e-97f6c14ddd60'
          }
        }
      }
    }
  }

  it 'gets all accounts to be removed' do
    Plink::IntuitAccountToRemoveRecord.should_receive(:all).and_return([])

    subject.invoke
  end

  it 'removes accounts from intuit that are in intuit_accounts_to_remove' do
    users_institution = create_users_institution(is_active: true)
    create_user_reverification(users_institution_id: users_institution.id, is_active: true)
    create_user_intuit_error(users_institution_id: users_institution.id)
    create_intuit_fishy_transaction(users_institution_id: users_institution.id, is_active: true)

    account_to_remove = create_intuit_account_to_remove(
      intuit_account_id: 23,
      users_institution_id: users_institution.id,
      user_id: 13
    )
    create_users_institution_account(users_institution_id: users_institution.id, account_id: 23, is_active: true, in_intuit: true)
    create_users_institution_account_staging(users_institution_id: users_institution.id, account_id: 23, in_intuit: true)

    aggcat_client = double(delete_account: not_found_delete_response)
    Aggcat.stub(:scope).with(13).and_return(aggcat_client)
    aggcat_client.should_receive(:delete_account).with(23).and_return(successful_delete_response)

    Plink::UserReverificationRecord.where(isActive: true).length.should == 1
    Plink::UserIntuitErrorRecord.all.length.should == 1
    Plink::IntuitFishyTransactionRecord.where(is_active: true).length.should == 1
    Plink::UsersInstitutionAccountRecord.where(isActive: true).length.should == 1
    Plink::UsersInstitutionAccountRecord.where(inIntuit: true).length.should == 1
    Plink::UsersInstitutionAccountStagingRecord.where(inIntuit: true).length.should == 1
    Plink::IntuitAccountToRemoveRecord.all.length.should == 1

    subject.invoke

    Plink::UserReverificationRecord.where(isActive: true).length.should == 0
    Plink::UserIntuitErrorRecord.all.length.should == 0
    Plink::IntuitFishyTransactionRecord.where(is_active: true).length.should == 0
    Plink::UsersInstitutionAccountRecord.where(isActive: true).length.should == 0
    Plink::UsersInstitutionAccountRecord.where(inIntuit: true).length.should == 0
    Plink::UsersInstitutionAccountStagingRecord.where(inIntuit: true).length.should == 0
    Plink::IntuitAccountToRemoveRecord.all.length.should == 0
  end

  context 'when the delete returns a status code 200 or 404' do
    let!(:intuit_account_to_remove) {
      create_intuit_account_to_remove(
        intuit_account_id: 23,
        users_institution_id: 3,
        user_id: 13
      )
    }

    let(:where_return) { double(:update_all) }

    before do
      Aggcat.stub(:scope).and_return(aggcat_client)
      Plink::UsersInstitutionAccountRecord.stub(where: double(update_all: true))
      Plink::UsersInstitutionAccountStagingRecord.stub(where: double(update_all: true))
      Plink::UsersInstitutionRecord.stub(:find).and_return(users_institution)
    end

    context 'with a 200' do
      let(:aggcat_client) { double(delete_account: successful_delete_response) }
      let(:users_institution) { double(users_institution_account_records: double(where: ['one thing'])) }

      it 'sets the users institution account to is_active = 0 and in_intuit = 0' do
        Plink::UsersInstitutionAccountRecord.unstub(:where)

        Plink::UsersInstitutionAccountRecord.should_receive(:where).
          with('accountID = ?', intuit_account_to_remove.intuit_account_id).
          and_return(where_return)

        where_return.should_receive(:update_all).
          with(isActive: false, inIntuit: false, endDate: Date.current)

        subject.invoke
      end

      it 'sets the users institution account staging to is_active = 0 and in_intuit = 0' do
        Plink::UsersInstitutionAccountStagingRecord.unstub(:where)

        Plink::UsersInstitutionAccountStagingRecord.should_receive(:where).
          with('accountID = ?', intuit_account_to_remove.intuit_account_id).
          and_return(where_return)

        where_return.should_receive(:update_all).
          with(inIntuit: false)

        subject.invoke
      end

      it 'deletes the intuit account to remove record' do
        Plink::IntuitAccountToRemoveRecord.should_receive(:destroy).with(intuit_account_to_remove.id)

        subject.invoke
      end

      context 'if it is the last active account for a users institution' do
        let(:users_institution) { double(id: 3, update_attributes: true, users_institution_account_records: double(where: [])) }
        let(:destroy_return) { double(:destroy_all) }

        before do
          Plink::UserReverificationRecord.stub(where: double(update_all: true))
          Plink::UserIntuitErrorRecord.stub(where: double(destroy_all: true))
          Plink::IntuitFishyTransactionRecord.stub(where: double(update_all: true))
        end

        it 'sets the users institution to is_active = 0' do
          users_institution.should_receive(:update_attributes).
            with(is_active: false)

          subject.invoke
        end

        it 'sets all reverifications for the users institution to is_active = 0' do
          Plink::UserReverificationRecord.unstub(:where)

          Plink::UserReverificationRecord.should_receive(:where).
            with('usersInstitutionID = ?', 3).
            and_return(where_return)

          where_return.should_receive(:update_all).
            with(isActive: false)

          subject.invoke
        end

        it 'deletes all users intuit errors for the users institution' do
          Plink::UserIntuitErrorRecord.unstub(:where)

          Plink::UserIntuitErrorRecord.should_receive(:where).
            with('usersInstitutionID = ?', 3).
            and_return(destroy_return)

          destroy_return.should_receive(:destroy_all)

          subject.invoke
        end

        it 'sets all intuit_fishy_transactions for the users institution to is_active = 0' do
          Plink::IntuitFishyTransactionRecord.unstub(:where)

          Plink::IntuitFishyTransactionRecord.should_receive(:where).
            with('users_institution_id = ?', 3).
            and_return(where_return)

          where_return.should_receive(:update_all).
            with(is_active: false)

          subject.invoke
        end
      end
    end
  end
end
