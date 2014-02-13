require 'spec_helper'

describe Intuit::AccountRemovalService do
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

  let(:intuit_request) { double }

  before do
    Intuit::Request.stub(:new).and_return(intuit_request)
  end

  it 'removes accounts from intuit that are in intuit_accounts_to_remove' do
    users_institution = create_users_institution(is_active: true)
    create_user_reverification(users_institution_id: users_institution.id, is_active: true)
    create_user_intuit_error(users_institution_id: users_institution.id)
    create_intuit_fishy_transaction(users_institution_id: users_institution.id, is_active: true)

    create_users_institution_account(users_institution_id: users_institution.id, account_id: 23, is_active: true, in_intuit: true)
    create_users_institution_account_staging(users_institution_id: users_institution.id, account_id: 23, in_intuit: true)

    intuit_request.should_receive(:delete_account).with(23).and_return(successful_delete_response)

    Plink::UsersInstitutionRecord.where(isActive: true).length.should == 1
    Plink::UserReverificationRecord.where(isActive: true).length.should == 1
    Plink::UserIntuitErrorRecord.all.length.should == 1
    Plink::IntuitFishyTransactionRecord.where(is_active: true).length.should == 1
    Plink::UsersInstitutionAccountRecord.where(isActive: true).length.should == 1
    Plink::UsersInstitutionAccountRecord.where(inIntuit: true).length.should == 1
    Plink::UsersInstitutionAccountStagingRecord.where(inIntuit: true).length.should == 1

    Intuit::AccountRemovalService.remove(23, 13, users_institution.id)

    Plink::UsersInstitutionRecord.where(isActive: true).length.should == 0
    Plink::UserReverificationRecord.where(isActive: true).length.should == 0
    Plink::UserIntuitErrorRecord.all.length.should == 0
    Plink::IntuitFishyTransactionRecord.where(is_active: true).length.should == 0
    Plink::UsersInstitutionAccountRecord.where(isActive: true).length.should == 0
    Plink::UsersInstitutionAccountRecord.where(inIntuit: true).length.should == 0
    Plink::UsersInstitutionAccountStagingRecord.where(inIntuit: true).length.should == 0
  end

  context 'when the delete returns a status code 200 or 404' do
    let(:where_return) { double(:update_all) }

    before do
      Plink::UsersInstitutionAccountRecord.stub(where: double(update_all: true))
      Plink::UsersInstitutionAccountStagingRecord.stub(where: double(update_all: true))
      Plink::UsersInstitutionRecord.stub(:find).and_return(users_institution)
    end

    context 'with a 200' do
      let(:intuit_request) { double(delete_account: successful_delete_response) }
      let(:users_institution) { double(users_institution_account_records: double(where: ['one thing'])) }

      it 'sets the users institution account to is_active = 0 and in_intuit = 0' do
        Plink::UsersInstitutionAccountRecord.unstub(:where)

        Plink::UsersInstitutionAccountRecord.should_receive(:where).
          with('accountID = ?', 23).
          and_return(where_return)

        where_return.should_receive(:update_all).
          with(isActive: false, inIntuit: false, endDate: Date.current)

        Intuit::AccountRemovalService.remove(23, 13, 3)
      end

      it 'sets the users institution account staging to is_active = 0 and in_intuit = 0' do
        Plink::UsersInstitutionAccountStagingRecord.unstub(:where)

        Plink::UsersInstitutionAccountStagingRecord.should_receive(:where).
          with('accountID = ?', 23).
          and_return(where_return)

        where_return.should_receive(:update_all).
          with(inIntuit: false)

        Intuit::AccountRemovalService.remove(23, 13, 3)
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

          Intuit::AccountRemovalService.remove(23, 13, 3)
        end

        it 'sets all reverifications for the users institution to is_active = 0' do
          Plink::UserReverificationRecord.unstub(:where)

          Plink::UserReverificationRecord.should_receive(:where).
            with('usersInstitutionID = ?', 3).
            and_return(where_return)

          where_return.should_receive(:update_all).
            with(isActive: false)

          Intuit::AccountRemovalService.remove(23, 13, 3)
        end

        it 'deletes all users intuit errors for the users institution' do
          Plink::UserIntuitErrorRecord.unstub(:where)

          Plink::UserIntuitErrorRecord.should_receive(:where).
            with('usersInstitutionID = ?', 3).
            and_return(destroy_return)

          destroy_return.should_receive(:destroy_all)

          Intuit::AccountRemovalService.remove(23, 13, 3)
        end

        it 'sets all intuit_fishy_transactions for the users institution to is_active = 0' do
          Plink::IntuitFishyTransactionRecord.unstub(:where)

          Plink::IntuitFishyTransactionRecord.should_receive(:where).
            with('users_institution_id = ?', 3).
            and_return(where_return)

          where_return.should_receive(:update_all).
            with(is_active: false)

          Intuit::AccountRemovalService.remove(23, 13, 3)
        end
      end
    end
  end
end
