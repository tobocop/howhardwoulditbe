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

    describe '.wallets_eligible_for_transaction_unlocks' do
      let!(:user) { create_user(email: 'ares@example.com') }
      let!(:wallet) { create_wallet(user_id: user.id) }
      let!(:foo) { 3.times { |i| create_open_wallet_item(wallet_id: wallet.id) } }

      subject(:wallets_eligible_for_transaction_unlocks) { Plink::WalletRecord.wallets_eligible_for_transaction_unlocks }

      context 'for users who have not unlocked any wallet items' do
        it 'returns a collection of wallets that does not include their wallet' do
          create_locked_wallet_item(wallet_id: wallet.id)
          wallets_eligible_for_transaction_unlocks.should_not include wallet
        end
      end

      context 'for users who have a qualifying transaction and have not unlocked the transaction slot' do
        it 'returns a collection of wallets that includes their wallet' do
          create_qualifying_award(user_id: user.id)
          create_locked_wallet_item(wallet_id: wallet.id)
          wallet.reload
          wallets_eligible_for_transaction_unlocks.should include wallet
        end
      end

      context 'for users who have a qualifying transaction, but have already unlocked the transaction slot' do
        it 'returns a collection of wallets that does not include their wallet' do
          create_qualifying_award(user_id: user.id)
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
      it 'returns the string transaction' do
        Plink::WalletRecord.transaction_unlock_reason.should == 'transaction'
      end
    end

    describe '.join_unlock_reason' do
      it 'returns the string join' do
        Plink::WalletRecord.join_unlock_reason.should == 'join'
      end
    end

    describe '.referral_unlock_reason' do
      it 'returns the string referral' do
        Plink::WalletRecord.referral_unlock_reason.should == 'referral'
      end
    end

    describe '.current_promotion_unlock_reason' do
      it 'returns the string promotion_app_install' do
        Plink::WalletRecord.current_promotion_unlock_reason.should == 'app_install_promotion'
      end
    end

    describe '.transaction_promotion_unlock_reason' do
      it 'returns the string promotion' do
        Plink::WalletRecord.transaction_promotion_unlock_reason.should == 'promotion'
      end
    end

    describe '.app_install_promotion_unlock_reason' do
      it 'returns the string app_install_promotion' do
        Plink::WalletRecord.app_install_promotion_unlock_reason.should == 'app_install_promotion'
      end
    end
  end

  describe '#has_offers_virtual_currency' do
    let(:wallet) { create_wallet }

    before do
      create_populated_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: 4)
      create_populated_wallet_item(wallet_id: wallet.id, offers_virtual_currency_id: 9)
    end

    it 'returns true if the provided offers_virtual_currency_id is in the wallet' do
      wallet.has_offers_virtual_currency(4).should be_true
      wallet.has_offers_virtual_currency(9).should be_true
    end

    it 'returns false if the provided offers_virtual_currency_id is not in the wallet' do
      wallet.has_offers_virtual_currency(6).should be_false
    end
  end
end
