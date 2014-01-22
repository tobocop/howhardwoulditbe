require 'spec_helper'

describe Plink::WalletItemUnlockingService do
  subject(:service) { Plink::WalletItemUnlockingService }

  let!(:user) { create_user(email: 'user_with_locked_wallet_item@example.com') }
  let!(:wallet) { create_wallet(user_id: user.id) }

  describe '.unlock_transaction_items_for_eligible_users' do

    before do
      create_qualifying_award(user_id: user.id)
      create_locked_wallet_item(wallet_id: wallet.id)
      create_locked_wallet_item(wallet_id: wallet.id)
    end

    it 'unlocks only one locked wallet item per invocation' do
      wallet.locked_wallet_items.length.should == 2
      service.unlock_transaction_items_for_eligible_users
      wallet.reload.locked_wallet_items.length.should == 1
    end

    it 'sets the reason that the wallet item was unlocked' do
      service.unlock_transaction_items_for_eligible_users
      wallet_item = wallet.reload.open_wallet_items.first
      wallet_item.unlock_reason.should == 'transaction'
    end

    it 'converts a locked wallet item into an open wallet item' do
      wallet.open_wallet_items.length.should == 0
      service.unlock_transaction_items_for_eligible_users
      wallet.reload.open_wallet_items.length.should == 1
    end

    it 'sets the type for the wallet item' do
      service.unlock_transaction_items_for_eligible_users
      wallet_item = wallet.reload.open_wallet_items.first
      wallet_item.type.should == 'Plink::OpenWalletItemRecord'
    end

    it 'handles NULL walletItem.type values gracefully' do
      wallet.wallet_item_records.each do |wallet_item_record|
        wallet_item_record.type = nil
        wallet_item_record.save!
      end
      wallet.reload

      expect {
        service.unlock_transaction_items_for_eligible_users
      }.not_to raise_error()
    end
  end

  describe '.unlock_wallet_item_record' do
    let(:wallet_item_record) { create_locked_wallet_item }
    let(:reason) { Plink::WalletRecord::UNLOCK_REASONS[:join] }

    it 'unlocks the given WalletItemRecord with the given reason' do
      wallet_item_record.type.should == 'Plink::LockedWalletItemRecord'

      service.unlock_wallet_item_record(wallet_item_record, reason)

      wallet_item_record.unlock_reason.should == reason
      wallet_item_record.type.should == 'Plink::OpenWalletItemRecord'
    end

    it 'returns true when successful' do
      service.unlock_wallet_item_record(wallet_item_record, reason).should be_true
    end

    it 'returns false when unsuccessful' do
      wallet_item_record.stub(:save).and_return(false)

      service.unlock_wallet_item_record(wallet_item_record, reason).should be_false
    end
  end

  describe '.unlock_referral_slot' do
    let(:wallet_record) { double(Plink::WalletRecord, unlocked_referral_slot?: false, locked_wallet_items: []) }
    let(:user_record) { double(Plink::UserRecord, wallet: wallet_record)}
    let(:wallet_service) { double(Plink::WalletService) }

    before do
      Plink::UserRecord.stub(:find).and_return(user_record)
      Plink::WalletRecord.stub(:referral_unlock_reason).and_return('another_referral')
    end

    it 'looks up the users wallet' do
      Plink::UserRecord.should_receive(:find).with(23).and_return(user_record)
      user_record.should_receive(:wallet).and_return(wallet_record)

      Plink::WalletItemUnlockingService.unlock_referral_slot(23)
    end

    context 'when the referral slot is already unlocked' do
      let(:wallet_record) { double(Plink::WalletRecord, unlocked_referral_slot?: true) }

      it 'does not call unlock' do
        Plink::WalletItemUnlockingService.should_not_receive(:unlock)

        Plink::WalletItemUnlockingService.unlock_referral_slot(23)
      end
    end

    context 'when the referral slot is not already unlocked' do
      it 'unlocks the referral slot' do
        Plink::WalletItemUnlockingService.should_receive(:unlock).with(wallet_record, 'another_referral')

        Plink::WalletItemUnlockingService.unlock_referral_slot(23)
      end
    end
  end
end
