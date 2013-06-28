require 'spec_helper'

describe Plink::WalletCreationService do

  class Plink::WalletRecord; end
  class Plink::WalletItemRecord; end

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
      service.create_for_user_id
    end

    it 'creates x amount of walletItems that are empty' do
      Plink::WalletCreationService.stub(:default_creation_slot_count) { 10 }
      service = Plink::WalletCreationService.new(user_id: 132)
      wallet_stub = stub(id:1423)
      Plink::WalletRecord.stub(:create).and_return { wallet_stub }

      1.upto(10) do |i|
        Plink::WalletItemRecord.should_receive(:create).with(wallet_id: 1423, wallet_slot_id: i)
      end

      service.create_for_user_id
    end
  end

end