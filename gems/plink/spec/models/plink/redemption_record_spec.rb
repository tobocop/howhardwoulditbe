require 'spec_helper'

describe Plink::RedemptionRecord do

  let(:valid_params) {
    {
      dollar_award_amount: 2.3,
      reward_id: 2,
      user_id: 1,
      is_pending: true,
      is_active: true
    }
  }

  subject { Plink::RedemptionRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'should be persisted' do
    Plink::RedemptionRecord.create(valid_params).should be_persisted
  end
end

