require 'spec_helper'

describe Plink::WalletItem do
  describe 'in_use?' do
    it 'returns true if wallet item record has a offers_virtual_currency_id' do
      Plink::WalletItem.new(stub(offers_virtual_currency_id: 123)).should be_in_use
    end

    it 'returns false if wallet item record does not have a offers_virtual_currency_id' do
      Plink::WalletItem.new(stub(offers_virtual_currency_id: nil)).should_not be_in_use
    end
  end

  describe 'locked?' do
    it 'returns true if the item is locked' do
      locked_wallet_item_record = new_locked_wallet_item
      Plink::WalletItem.new(locked_wallet_item_record).should be_locked
    end

    it 'returns false if the item is populated' do
      populated_wallet_item_record = new_wallet_item(offers_virtual_currency_id: 12)
      Plink::WalletItem.new(populated_wallet_item_record).should_not be_locked
    end

    it 'returns false if the item is empty' do
      empty_wallet_item = new_wallet_item()
      Plink::WalletItem.new(empty_wallet_item).should_not be_locked
    end
  end

  it 'returns its associated offer' do
    offer = stub
    offer_record = stub
    wallet_item_record = stub(offer: offer_record, offers_virtual_currency: stub(virtual_currency_id: 123))
    Plink::Offer.should_receive(:new).with(offer_record, 123) { offer }
    presenter = Plink::WalletItem.new(wallet_item_record)
    presenter.offer.should == offer
  end
end