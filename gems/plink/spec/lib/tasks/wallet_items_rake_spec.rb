require 'spec_helper'

describe 'wallet_items:unlock_transaction_wallet_item' do
  include_context 'rake'

  before(:each) do
    @user_with_no_qualified_transactions = create_user(email: 'cosmo@example.com')
    @no_qualified_transactions_wallet = create_wallet(user_id: @user_with_no_qualified_transactions.id)
    create_locked_wallet_item(wallet_id: @no_qualified_transactions_wallet.id)

    @user_with_pending_qualified_transactions = create_user(email: 'newman@example.com')
    @pending_qualified_transactions_wallet = create_wallet(user_id: @user_with_pending_qualified_transactions.id)
    create_locked_wallet_item(wallet_id: @pending_qualified_transactions_wallet.id)
    create_open_wallet_item(wallet_id: @pending_qualified_transactions_wallet.id)
    create_qualifying_award(user_id: @user_with_pending_qualified_transactions.id)

    @user_previously_unlocked = create_user(email: 'elaine@example.com')
    @previously_unlocked_wallet = create_wallet(user_id: @user_previously_unlocked.id)
    create_qualifying_award(user_id: @user_previously_unlocked.id)
    create_open_wallet_item(wallet_id: @previously_unlocked_wallet.id, unlock_reason: 'transaction')
  end

  it 'does not unlock wallet items for users without qualifying transactions' do
    @no_qualified_transactions_wallet.locked_wallet_items.size.should == 1
    @no_qualified_transactions_wallet.open_wallet_items.should be_empty
    subject.invoke
    @no_qualified_transactions_wallet.reload
    @no_qualified_transactions_wallet.reload.locked_wallet_items.size.should == 1
    @no_qualified_transactions_wallet.open_wallet_items.should be_empty
  end

  it 'unlocks wallet items for eligible users' do
    @pending_qualified_transactions_wallet.open_wallet_items.size.should == 1
    @pending_qualified_transactions_wallet.locked_wallet_items.size.should == 1
    subject.invoke
    @pending_qualified_transactions_wallet.reload
    @pending_qualified_transactions_wallet.open_wallet_items.size.should == 2
    @pending_qualified_transactions_wallet.reload.locked_wallet_items.size.should == 0
  end

  it 'does not unlock wallet items for users who had previously unlocked' do
    @previously_unlocked_wallet.open_wallet_items.size.should == 1
    @previously_unlocked_wallet.locked_wallet_items.should be_empty
    subject.invoke
    @previously_unlocked_wallet.reload.open_wallet_items.size.should == 1
    @previously_unlocked_wallet.locked_wallet_items.should be_empty
  end

end
