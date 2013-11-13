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

