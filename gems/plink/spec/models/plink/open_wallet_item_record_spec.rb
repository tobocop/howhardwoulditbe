require 'spec_helper'

describe Plink::OpenWalletItemRecord do

  let(:valid_params) {
    {
      wallet_id: 173,
      wallet_slot_id: 3,
      wallet_slot_type_id: 5
    }
  }

  subject { Plink::OpenWalletItemRecord.new(valid_params) }

  it 'is open' do
    subject.open?.should == true
  end

  describe 'assign_offer' do
    it 'assigns the offer to itself' do
      subject.assign_offer(double(id: 123), double(id: 456))
      subject.offers_virtual_currency_id.should == 123
      subject.should_not be_changed
    end

    it 'assigns the award_period to itself' do
      subject.assign_offer(double(id: 123), double(id: 456))
      subject.users_award_period_id.should == 456
      subject.should_not be_changed
    end

    it 'becomes a PopulatedWalletItemRecord' do
      subject.save!
      subject.assign_offer(double(id: 123), double(id: 456))
      Plink::PopulatedWalletItemRecord.last.id.should == subject.id
    end
  end
end
