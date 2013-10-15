require 'spec_helper'

describe Plink::Wallet do
  let(:wallet_record) { double(id:123) }
  subject { Plink::Wallet.new(wallet_record) }

  describe 'wallet_item_for_offer' do
    it 'finds the wallet item that matches the given offer param' do
      expected_wallet_item = double(offers_virtual_currency_id: 123)
      wallet_record.stub(:wallet_item_records) { [double(offers_virtual_currency_id: 456), expected_wallet_item] }
      offers_virtual_currency = double(id: 123)

      subject.wallet_item_for_offer(offers_virtual_currency).should == expected_wallet_item
    end

    it 'returns nil when no wallet item matches' do
      wallet_record.stub(:wallet_item_records) { [double(offers_virtual_currency_id: 456)] }
      offers_virtual_currency = double(id: 123)

      subject.wallet_item_for_offer(offers_virtual_currency).should be_nil
    end
  end

  describe '#has_unlocked_promotion_slot' do
    let(:no_promotion_wallet) {
      new_wallet(
        wallet_item_records: [
          new_open_wallet_item(unlock_reason: 'referral'),
          new_open_wallet_item(unlock_reason: 'join')
        ]
      )
    }

    let(:has_promotion_wallet) {
      new_wallet(
        wallet_item_records: [
          new_open_wallet_item(unlock_reason: 'promotion'),
          new_open_wallet_item(unlock_reason: 'join')
        ]
      )
    }

    it 'returns true if the wallet has an open_wallet_item with unlock_reason of promotion' do
      wallet = Plink::Wallet.new(has_promotion_wallet)
      wallet.has_unlocked_promotion_slot.should be_true
    end

    it 'returns false if the wallet does not have an open_wallet_item with unlock_reason of promotion' do
      wallet = Plink::Wallet.new(no_promotion_wallet)
      wallet.has_unlocked_promotion_slot.should be_false
    end
  end

  it 'returns the id of the wallet record it was initialized with' do
    subject.id.should == 123
  end

end