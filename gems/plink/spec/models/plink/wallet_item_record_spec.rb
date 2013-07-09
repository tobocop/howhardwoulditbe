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
end