require 'spec_helper'

describe Plink::PopulatedWalletItemRecord do

  let(:valid_params) {
    {
      wallet_id: 173,
      wallet_slot_id: 3,
      wallet_slot_type_id: 5
    }
  }

  subject { Plink::PopulatedWalletItemRecord.new(valid_params) }

  it 'is populated' do
    subject.populated?.should be_true
  end

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

  it 'returns an offers_virtual_currency_id' do
    wallet_item = Plink::WalletItemRecord.new(valid_params.merge(offers_virtual_currency_id: 123))
    wallet_item.offers_virtual_currency_id.should == 123
  end

  describe 'unassign_offer' do
    it 'clears the assigned offer' do
      subject.offers_virtual_currency_id = 123
      subject.save!

      subject.unassign_offer.should
      subject.offers_virtual_currency_id.should be_nil
      subject.should_not be_changed
    end

    it 'clears the assigned award period' do
      subject.users_award_period_id = 123
      subject.save!

      subject.unassign_offer
      subject.users_award_period_id.should be_nil
      subject.should_not be_changed
    end

    it 'becomes an OpenWalletItemRecord' do
      subject.users_award_period_id = 123
      subject.save!

      subject.unassign_offer
      Plink::OpenWalletItemRecord.last.id.should == subject.id
    end
  end
end