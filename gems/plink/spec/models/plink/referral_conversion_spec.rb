require 'spec_helper'

describe Plink::ReferralConversionRecord do

  let(:valid_params) {
    {
      referred_by: 1,
      created_user_id: 10
    }
  }

  subject { new_referral(valid_params) }

  it 'can be persisted' do
    Plink::ReferralConversionRecord.create(valid_params).should be_persisted
  end

end
