require 'spec_helper'

describe Plink::RewardAmountRecord do

  let(:valid_params) {
    {
      dollar_award_amount: 134,
      is_active: true,
      reward_id: 1
    }
  }

  subject {Plink::RewardAmountRecord.new(valid_params)}

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::RewardAmountRecord.create(valid_params).should be_persisted
  end
end
