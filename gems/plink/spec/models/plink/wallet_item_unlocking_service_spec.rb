require 'spec_helper'

describe Plink::WalletItemUnlockingService do
  subject(:service) { Plink::WalletItemUnlockingService }

  let!(:user) { create_user(email: 'user_with_locked_wallet_item@example.com') }
  let!(:wallet) { create_wallet(user_id: user.id) }
  let!(:qualifying_transaction) { create_qualifying_award(user_id: user.id) }

  describe '.unlock' do
    before do
      create_locked_wallet_item(wallet_id: wallet.id)
      create_locked_wallet_item(wallet_id: wallet.id)
    end

    it 'unlocks only one locked wallet item per invocation' do
      wallet.locked_wallet_items.length.should == 2
      service.unlock(wallet, Plink::WalletRecord::UNLOCK_REASONS[:transaction])
      wallet.reload.locked_wallet_items.length.should == 1
    end

    it 'sets the reason that the wallet item was unlocked' do
      service.unlock(wallet, Plink::WalletRecord::UNLOCK_REASONS[:transaction])
      wallet_item = wallet.reload.open_wallet_items.first
      wallet_item.unlock_reason.should == 'transaction'
    end

    it 'converts a locked wallet item into an open wallet item' do
      wallet.open_wallet_items.length.should == 0
      service.unlock(wallet, Plink::WalletRecord::UNLOCK_REASONS[:transaction])
      wallet.reload.open_wallet_items.length.should == 1
    end

    it 'sets the type for the wallet item' do
      service.unlock(wallet, Plink::WalletRecord::UNLOCK_REASONS[:transaction])
      wallet_item = wallet.reload.open_wallet_items.first
      wallet_item.unlock_reason.should == 'transaction'
      wallet_item.type.should == 'Plink::OpenWalletItemRecord'
    end

    it 'handles NULL walletItem.type values gracefully' do
      wallet.wallet_item_records.each do |wallet_item_record|
        wallet_item_record.type = nil
        wallet_item_record.save!
      end
      wallet.reload
      expect {
        service.unlock(wallet, Plink::WalletRecord::UNLOCK_REASONS[:transaction])
      }.not_to raise_exception(NoMethodError)
    end
  end

end
