require 'spec_helper'

describe Plink::WalletItemService do
  describe '.create_open_wallet_item' do
    it 'creates an open wallet item from a wallet_id and an unlock_reason' do
      create_args = {
        wallet_id: 14,
        wallet_slot_id: 1,
        wallet_slot_type_id: 1,
        unlock_reason: 'join'
      }
      Plink::OpenWalletItemRecord.should_receive(:create).with(create_args)

      Plink::WalletItemService.create_open_wallet_item(14, 'join')
    end
  end

  describe '#get_for_user_id' do
    let(:user) { create_user }
    let(:wallet) { create_wallet(user_id: user.id) }

    before do
      create_open_wallet_item(wallet_id: wallet.id)
      create_locked_wallet_item(wallet_id: wallet.id)
    end

    it 'returns wallet_items for a given user_id' do
      wallet_items = Plink::WalletItemService.new.get_for_wallet_id(wallet.id)
      wallet_items.length.should == 2
      wallet_items.map(&:class).uniq.should == [Plink::WalletItem]
    end

    it 'uses sorted wallet items' do
      Plink::WalletItem.any_instance.stub(:new) { double }
      Plink::WalletRecord.stub(:find) { wallet }

      wallet.should_receive(:sorted_wallet_item_records).and_call_original

      Plink::WalletItemService.new.get_for_wallet_id(wallet.id)
    end
  end
end
