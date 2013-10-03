require 'spec_helper'

describe Plink::WalletRecord do
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:wallet_item_records) }

  let(:valid_params) {
    {
      user_id: 143
    }
  }

  subject { Plink::WalletRecord.new(valid_params) }
  it_should_behave_like(:legacy_timestamps)

  describe 'named scopes' do
    describe '.wallets_with_locked_wallet_items' do

      let!(:user) { create_user(email: 'xena@example.com') }
      let!(:wallet) { create_wallet(user_id: user.id) }
      let!(:foo) { 3.times { |i| create_open_wallet_item(wallet_id: wallet.id) } }

      subject(:wallets_with_locked_wallet_items) { Plink::WalletRecord.wallets_with_locked_wallet_items }

      context 'for users who have not unlocked any wallet items' do
        let!(:locked_wallet_item_transaction) { create_locked_wallet_item(wallet_id: wallet.id) }

        it 'returns a collection that includes their wallet' do
          wallets_with_locked_wallet_items.should include wallet
        end
      end

      context 'for users who have unlocked a wallet item by transaction (only)' do
        let!(:locked_wallet_item_transaction) { create_locked_wallet_item(wallet_id: wallet.id) }

        it 'returns an empty collection' do
          wallets_with_locked_wallet_items.should include wallet
        end
      end
    end

    describe '.wallets_of_users_with_qualifying_transactions' do

      let!(:user) { create_user(email: 'callisto@example.com') }
      let!(:wallet) { create_wallet(user_id: user.id) }
      let!(:foo) { 3.times { |i| create_open_wallet_item(wallet_id: wallet.id) } }

      subject(:wallets_of_users_with_qualifying_transactions) { Plink::WalletRecord.wallets_of_users_with_qualifying_transactions }

      context 'for users who have a qualifying transaction' do
        let!(:locked_wallet_item_transaction) { create_locked_wallet_item(wallet_id: wallet.id) }
        let!(:qualifying_transaction) { create_qualifying_award(user_id: user.id) }

        it 'returns a collection of wallets that include the user\'s wallet' do
          wallets_of_users_with_qualifying_transactions.should include wallet
        end
      end

      context 'for users who do not have a qualifying transaction' do
        let!(:locked_wallet_item_transaction) { create_locked_wallet_item(wallet_id: wallet.id) }

        it 'returns a collection of wallets that do not include the user' 's wallet' do
          wallets_of_users_with_qualifying_transactions.should_not include wallet
        end
      end

    end

    describe '.wallets_without_unlocked_transaction_wallet_items' do

      let!(:user) { create_user(email: 'callisto@example.com') }
      let!(:wallet) { create_wallet(user_id: user.id) }
      let!(:foo) { 3.times { |i| create_open_wallet_item(wallet_id: wallet.id) } }

      subject(:wallets_without_unlocked_transaction_wallet_items) { Plink::WalletRecord.wallets_without_unlocked_transaction_wallet_items }

      context 'for users who have a transaction locked wallet item' do

        it 'returns a collection of walletID values that does not include their wallet' do
          create_locked_wallet_item(wallet_id: wallet.id, unlock_reason: 'transaction')
          wallets_without_unlocked_transaction_wallet_items.should_not include wallet.id
        end
      end

      context 'for users who do not have a transaction locked wallet item' do

        it 'returns a collection of walletID values that includes their wallet' do
          create_locked_wallet_item(wallet_id: wallet.id)
          wallets_without_unlocked_transaction_wallet_items.should_not include wallet.id
        end
      end
    end

    describe '.wallets_eligible_for_transaction_unlocks' do

      let!(:user) { create_user(email: 'ares@example.com') }
      let!(:wallet) { create_wallet(user_id: user.id) }
      let!(:foo) { 3.times { |i| create_open_wallet_item(wallet_id: wallet.id) } }

      subject(:wallets_eligible_for_transaction_unlocks) { Plink::WalletRecord.wallets_eligible_for_transaction_unlocks }

      context 'for users who have not unlocked any wallet items' do
        it 'returns a collection of walletID values that does not include their wallet' do
          create_locked_wallet_item(wallet_id: wallet.id)
          wallets_eligible_for_transaction_unlocks.should_not include wallet
        end
      end

      context 'for users who have a qualifying transaction and have not unlocked the transaction slot' do
        it 'returns a collection of walletID values that includes their wallet' do
          create_qualifying_award(user_id: user.id)
          create_locked_wallet_item(wallet_id: wallet.id)
          wallet.reload
          wallets_eligible_for_transaction_unlocks.should include wallet
        end
      end

      context 'for users who have a qualifying transaction, but have already unlocked the transaction slot' do
        it 'returns a collection of walletID values that does not include their wallet' do
          create_locked_wallet_item(wallet_id: wallet.id, unlock_reason: 'transaction')
          wallets_eligible_for_transaction_unlocks.should_not include wallet
        end
      end
    end

    describe '.sorted_wallet_item_records' do
      let!(:wallet) { create_wallet }
      let!(:second_item) { create_open_wallet_item(wallet_id: wallet.id) }
      let!(:third_item) { create_locked_wallet_item(wallet_id: wallet.id) }
      let!(:first_item) { create_populated_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: 123) }

      it 'returns wallet items sorted by ones that are populated then ones that are unlocked' do
        ordered_items = [first_item, second_item, third_item]
        wallet.sorted_wallet_item_records.should == ordered_items
      end
    end
  end

  describe '.create' do
    it 'can be created' do
      Plink::WalletRecord.create(valid_params).should be_persisted
    end

    it 'requires a user_id' do
      Plink::WalletRecord.new(valid_params.except(:user_id)).should_not be_valid
    end
  end

  context 'constants' do
    describe '.transaction_unlock_reason' do
      it 'returns the string transaction for' do
        Plink::WalletRecord.transaction_unlock_reason.should == 'transaction'
      end
    end

    describe '.join_unlock_reason' do
      it 'returns the string join for' do
        Plink::WalletRecord.join_unlock_reason.should == 'join'
      end
    end

    describe '.referral_unlock_reason' do
      it 'returns the string referral for' do
        Plink::WalletRecord.referral_unlock_reason.should == 'referral'
      end
    end
  end

end
