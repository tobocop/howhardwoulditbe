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

  describe 'validations' do
    it 'validates that unlock_reason can be nil' do
      subject.should be_valid
    end
    it 'validates that unlock_reason is in the list' do
      subject.unlock_reason = 'join'
      subject.should be_valid
    end
    it 'validates that unlock_reason cannot be a value not in the list or nil' do
      subject.unlock_reason = ' '
      subject.should_not be_valid

      subject.unlock_reason = 'plink'
      subject.should_not be_valid
    end
  end

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

  describe 'named scopes' do
    describe '.open_records' do
      subject(:open_scope) { Plink::WalletItemRecord.open_records }

      let!(:open_wallet_item) { create_open_wallet_item }
      let!(:populated_wallet_item) { create_populated_wallet_item }
      let!(:locked_wallet_item) { create_locked_wallet_item }

      it "returns only open wallet item records" do
        open_scope.should include open_wallet_item
        open_scope.should_not include populated_wallet_item
        open_scope.should_not include locked_wallet_item
      end
    end

    describe '.populated_records' do
      subject(:populated_scope) { Plink::WalletItemRecord.populated_records }

      let!(:open_wallet_item) { create_open_wallet_item }
      let!(:populated_wallet_item) { create_populated_wallet_item }
      let!(:locked_wallet_item) { create_locked_wallet_item }

      it "returns only populated wallet item records" do
        populated_scope.should_not include open_wallet_item
        populated_scope.should include populated_wallet_item
        populated_scope.should_not include locked_wallet_item
      end
    end

    describe '.locked_records' do
      subject(:locked_scope) { Plink::WalletItemRecord.locked_records }

      let!(:open_wallet_item) { create_open_wallet_item }
      let!(:populated_wallet_item) { create_populated_wallet_item }
      let!(:locked_wallet_item) { create_locked_wallet_item }

      it "returns only locked wallet item records" do
        locked_scope.should_not include open_wallet_item
        locked_scope.should_not include populated_wallet_item
        locked_scope.should include locked_wallet_item
      end
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
