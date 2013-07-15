require 'spec_helper'

describe Plink::WalletItemRecord do

  let(:valid_params) {
    {
        wallet_id: 173,
        wallet_slot_id: 3,
        wallet_slot_type_id: 5
    }
  }

  subject { Plink::WalletItemRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  describe 'create' do
    it 'can be created' do
      Plink::WalletItemRecord.create(valid_params).should be_persisted
    end

    it 'requires a wallet_id' do
      Plink::WalletItemRecord.new(valid_params.except(:wallet_id)).should_not be_valid
    end

    it 'requires a wallet_slot_id' do
      Plink::WalletItemRecord.new(valid_params.except(:wallet_slot_id)).should_not be_valid
    end

    it 'requires a wallet_slot_type_id' do
      Plink::WalletItemRecord.new(valid_params.except(:wallet_slot_type_id)).should_not be_valid
    end
  end

  it 'defaults locked? to false' do
    subject.locked?.should be_false
  end

  it 'defaults populated? to false' do
    subject.populated?.should be_false
  end

  it 'defaults open? to false' do
    subject.open?.should be_false
  end

  it 'validates the uniqueness of offers within a wallet' do
    wallet = create_wallet
    create_populated_wallet_item(offers_virtual_currency_id: 1, wallet_id: wallet.id)
    create_open_wallet_item(offers_virtual_currency_id: nil, wallet_id: wallet.id)
    create_open_wallet_item(offers_virtual_currency_id: nil, wallet_id: wallet.id)
    create_populated_wallet_item(offers_virtual_currency_id: 1, wallet_id: create_wallet.id)
    invalid_record = new_populated_wallet_item(offers_virtual_currency_id: 1, wallet_id: wallet.id)

    Plink::WalletItemRecord.count.should == 4
    invalid_record.valid?.should be_false
    invalid_record.errors.full_messages.should == ['Offersvirtualcurrencyid has already been taken']
  end
end