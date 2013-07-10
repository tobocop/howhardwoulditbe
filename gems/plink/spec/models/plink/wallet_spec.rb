require 'spec_helper'

describe Plink::Wallet do
  let(:wallet_record) { stub(id:123) }
  subject { Plink::Wallet.new(wallet_record) }

  describe 'wallet_item_for_offer' do
    it 'finds the wallet item that matches the given offer param' do
      expected_wallet_item = stub(offers_virtual_currency_id: 123)
      wallet_record.stub(:wallet_items) { [stub(offers_virtual_currency_id: 456), expected_wallet_item] }
      offers_virtual_currency = stub(id: 123)

      subject.wallet_item_for_offer(offers_virtual_currency).should == expected_wallet_item
    end

    it 'returns nil when no wallet item matches' do
      wallet_record.stub(:wallet_items) { [stub(offers_virtual_currency_id: 456)] }
      offers_virtual_currency = stub(id: 123)

      subject.wallet_item_for_offer(offers_virtual_currency).should be_nil
    end
  end

  it 'returns the id of the wallet record it was initialized with' do
    subject.id.should == 123
  end

end