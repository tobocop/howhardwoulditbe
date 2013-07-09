require 'spec_helper'

describe Plink::LockedWalletItemRecord do

  let(:valid_params) {
    {
      wallet_id: 173,
      wallet_slot_id: 3,
      wallet_slot_type_id: 5
    }
  }

  subject { Plink::LockedWalletItemRecord.new(valid_params) }

  it 'is locked' do
    subject.locked?.should == true
  end

end