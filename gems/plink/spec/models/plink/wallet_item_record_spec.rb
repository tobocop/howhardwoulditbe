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

  it 'has an offers_virtual_currency' do
    ovc = create_offers_virtual_currency
    subject.offers_virtual_currency = ovc
    subject.save!

    subject.reload
    subject.offers_virtual_currency.should == ovc
  end

  it 'has an offer' do
    offer = create_offer
    ovc = create_offers_virtual_currency(offerID: offer.id)
    subject.offers_virtual_currency = ovc
    subject.save!

    subject.reload
    subject.offer.should == offer
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

  it 'returns an offers_virtual_currency_id' do
    wallet_item = Plink::WalletItemRecord.new(valid_params.merge(offers_virtual_currency_id: 123))
    wallet_item.offers_virtual_currency_id.should == 123
  end

  describe 'empty' do
    it 'includes empty items' do
      wallet_item = Plink::WalletItemRecord.new(valid_params.merge(offers_virtual_currency_id: nil))
      wallet_item.save

      Plink::WalletItemRecord.empty.should == [wallet_item]
    end

    it 'does not include taken items' do
      wallet_item = Plink::WalletItemRecord.new(valid_params.merge(offers_virtual_currency_id: 123))
      wallet_item.save

      Plink::WalletItemRecord.empty.should == []
    end
  end

  describe 'assign_offer' do
    it 'assigns the offer to itself' do
      subject.assign_offer(stub(id: 123))
      subject.offers_virtual_currency_id.should == 123
      subject.should_not be_changed
    end
  end

  describe 'unassign_offer' do
    it 'clears the assigned offer' do
      subject.offers_virtual_currency_id = 123
      subject.save!

      subject.unassign_offer
      subject.offers_virtual_currency_id.should be_nil
      subject.should_not be_changed
    end
  end
end