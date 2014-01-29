require 'spec_helper'

describe 'intuit:remove_accounts' do
  include_context 'rake'

  let!(:account_to_remove) {
    create_intuit_account_to_remove(
      intuit_account_id: 23,
      users_institution_id: 3,
      user_id: 13
    )
  }

  before do
    Intuit::AccountRemovalService.stub(:remove)
  end

  it 'gets all accounts to be removed' do
    Plink::IntuitAccountToRemoveRecord.should_receive(:all).and_return([])
    subject.invoke
  end

  it 'deletes the intuit account to remove record' do
    Plink::IntuitAccountToRemoveRecord.should_receive(:destroy).with(account_to_remove.id)
    subject.invoke
  end

  it 'queues the account removals to a named DJ queue' do
    Intuit::AccountRemovalService.unstub(:remove)
    delay_double = double(remove: true)

    Intuit::AccountRemovalService.should_receive(:delay)
      .with(queue: 'intuit_account_removals')
      .and_return(delay_double)
    delay_double.should_receive(:remove).with(23, 13, 3)

    subject.invoke
  end
end

describe 'intuit:remove_staged_accounts' do
  include_context 'rake'

  let(:intuit_account_removal_service) { double(remove: true) }
  let!(:account_to_remove) {
    create_users_institution_account_staging(
      account_id: 2,
      created: 3.days.ago,
      in_intuit: true,
      user_id: 4,
      users_institution_id: 3
    )
  }

  context 'when there are no exceptions' do
    before do
      Intuit::AccountRemovalService.stub(:delay).and_return(intuit_account_removal_service)
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'removes accounts in intuit that are two days old and not chosen' do
      intuit_account_removal_service.should_receive(:remove).with(2, 4, 3)

      subject.invoke
    end

    it 'does not remove accounts that are not two days old' do
      account_to_remove.update_attribute('created', 1.day.ago)

      intuit_account_removal_service.should_not_receive(:remove)

      subject.invoke
    end

    it 'does not remove accounts that have been chosen' do
      Plink::UsersInstitutionAccountRecord.create(account_to_remove.values_for_final_account)

      intuit_account_removal_service.should_not_receive(:remove)

      subject.invoke
    end

    it 'does not remove accounts that do not exist in intuit' do
      account_to_remove.update_attribute('inIntuit', false)

      intuit_account_removal_service.should_not_receive(:remove)

      subject.invoke
    end
  end

  context 'when there are exceptions' do
    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      ::Exceptional::Catcher.should_receive(:handle).with(/intuit:remove_staged_accounts/)

      Plink::UsersInstitutionAccountStagingRecord.stub(:joins).
        and_raise(ActiveRecord::ConnectionNotEstablished)


      subject.invoke
    end

    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      Intuit::AccountRemovalService.stub(:delay).and_raise(Exception)

      ::Exceptional::Catcher.should_receive(:handle).with(/intuit:remove_staged_accounts Rake task failed on users_institution_account_staging\.id =/)

      subject.invoke
    end
  end
end
