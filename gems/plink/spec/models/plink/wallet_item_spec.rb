require 'spec_helper'

describe Plink::WalletItem do

  it 'returns populated = true when its instantiated with a PopulatedWalletItemRecord' do
    item = Plink::WalletItem.new(new_populated_wallet_item)
    item.populated?.should be_true
  end

  it 'returns locked = true when its instantiated with a LockedWalletItemRecord' do
    item = Plink::WalletItem.new(new_locked_wallet_item)
    item.locked?.should be_true
  end

  it 'returns open = true when its instantiated with a OpenWalletItemRecord' do
    item = Plink::WalletItem.new(new_open_wallet_item)
    item.open?.should be_true
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