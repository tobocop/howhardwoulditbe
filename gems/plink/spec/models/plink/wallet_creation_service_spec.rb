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
      Plink::WalletRecord.should_receive(:create).with(user_id: 132) { double(id: 456) }
      Plink::WalletItemRecord.stub(:create)
      service.create_for_user_id(number_of_locked_slots: 1)
    end

    it 'creates x amount of open walletItems that have an unlock reason of join' do
      Plink::WalletCreationService.stub(:default_creation_slot_count) { 10 }

      service = Plink::WalletCreationService.new(user_id: 132)
      wallet = double(id: 1423)

      Plink::WalletRecord.stub(:create).and_return { wallet }

      Plink::WalletItemService.should_receive(:create_open_wallet_item)
        .with(1423, 'join').exactly(10).times

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
