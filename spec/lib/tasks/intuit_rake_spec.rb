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

describe 'intuit:remove_inactive_accounts' do
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

    it 'removes accounts of force deactivated users' do
      force_deactivated_user = create_user(is_force_deactivated: true)
      account_to_remove.update_attribute('created', 1.day.ago)
      account_to_remove.update_attribute('user_id', force_deactivated_user.id)

      intuit_account_removal_service.should_receive(:remove).with(2, force_deactivated_user.id, 3)

      subject.invoke
    end

    it 'does not remove accounts that are not two days old' do
      account_to_remove.update_attribute('created', 1.day.ago)

      intuit_account_removal_service.should_not_receive(:remove)

      subject.invoke
    end

    it 'does not remove accounts that have been chosen' do
      Plink::UsersInstitutionAccountRecord.create(account_to_remove.values_for_final_account)
      create_users_institution_account_staging(
        account_id: 2,
        created: 3.days.ago,
        in_intuit: true,
        user_id: 4,
        users_institution_id: 3
      )

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
      Plink::UsersInstitutionAccountStagingRecord.stub(:joins).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /intuit:remove_inactive_accounts/
      end

      subject.invoke
    end

    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      Intuit::AccountRemovalService.stub(:delay).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /intuit:remove_inactive_accounts Rake task failed on users_institution_account_staging\.id =/
      end

      subject.invoke
    end
  end
end

describe 'intuit:update_account_type' do
  include_context 'rake'

  let!(:users_institution_account) { create_users_institution_account }
  let(:intuit_request) { double(update_account_type: nil) }
  let(:valid_account_type) { 'debit' }

  it 'requires a users_institution_account_id argument' do
    expect {
      subject.invoke
    }.to raise_error ArgumentError
  end

  it 'requires an account_type argument' do
    expect {
      subject.invoke(78)
    }.to raise_error ArgumentError
  end

  it 'includes the user.id and users_institution_account_id if the Intuit login scope call fails' do
    Intuit::Request.stub(:new).and_return(nil)

    expect {
      subject.invoke(users_institution_account.id, valid_account_type)
    }.to raise_error(NoMethodError, /Could not set scope.*user\.id = \d+, users_institution_account_id = \d+/)
  end

  it 'looks up a users_institution_account record from the users_institution_account_id' do
    Intuit::Request.stub(:new).and_return(intuit_request)
    Plink::UsersInstitutionAccountRecord.should_receive(:find).with(users_institution_account.id).and_call_original

    subject.invoke(users_institution_account.id, valid_account_type)
  end

  it 'sets the correct scope in the intuit request' do
    Intuit::Request.stub(:new).with(users_institution_account.user_id).and_return(intuit_request)

    subject.invoke(users_institution_account.id, valid_account_type)
  end

  it 'allows the the account_type to be creditcard' do
    Intuit::Request.stub(:new).with(users_institution_account.user_id).and_return(intuit_request)

    expect {
      subject.invoke(users_institution_account.id, 'creditcard')
    }.not_to raise_error
  end

  it 'allows the the account_type to be debit' do
    Intuit::Request.stub(:new).with(users_institution_account.user_id).and_return(intuit_request)

    expect {
      subject.invoke(users_institution_account.id, 'debit')
    }.not_to raise_error
  end

  it 'displays an error if the account_type is invalid' do
    Intuit::Request.stub(:new).with(users_institution_account.user_id).and_return(intuit_request)

    expect {
      subject.invoke(users_institution_account.id, 'invalid_type')
    }.to raise_error(ArgumentError, /account_type is invalid/)
  end
end
