require 'spec_helper'

describe Plink::WalletCreationService do

  class Plink::WalletRecord;
  end
  class Plink::WalletItemRecord;
  end

  describe 'create_for_user_id' do
    it 'requires a user_id to be passed in' do
      expect {
        Plink::WalletCreationService.new()
      }.to raise_exception(KeyError, 'key not found: :user_id')
    end

    it 'creates a wallet record in the database' do
      service = Plink::WalletCreationService.new(user_id: 132)
      Plink::WalletRecord.should_receive(:create).with(user_id: 132) { stub(id: 456) }
      Plink::WalletItemRecord.stub(:create)
      service.create_for_user_id(number_of_locked_slots: 1)
    end

    it 'creates x amount of open walletItems that have an unlock reason of join' do
      Plink::WalletCreationService.stub(:default_creation_slot_count) { 10 }
      Plink::WalletCreationService.stub(:default_wallet_slot_type_id) { 1340 }

      service = Plink::WalletCreationService.new(user_id: 132)
      wallet_stub = stub(id: 1423)

      Plink::WalletRecord.stub(:create).and_return { wallet_stub }

      1.upto(10) do |i|
        wallet_item_params = {
          wallet_id: 1423,
          wallet_slot_id: i,
          wallet_slot_type_id: 1340,
          unlock_reason: 'join'
        }
        Plink::OpenWalletItemRecord.should_receive(:create).with(wallet_item_params)
      end

      service.create_for_user_id(number_of_locked_slots: 1)
    end

    it "creates the number of locked slots specified" do
      user = create_user
      service = Plink::WalletCreationService.new(user_id: user.id)

      expect {
        service.create_for_user_id(number_of_locked_slots: 2)
      }.to change { Plink::LockedWalletItemRecord.count }.by(2)
    end
  end

end
