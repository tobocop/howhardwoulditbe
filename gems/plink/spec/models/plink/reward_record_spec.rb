require 'spec_helper'

describe Plink::RewardRecord do

  let (:valid_params) {
    {
      award_code: 'walmart-gift-card',
      name: 'wally world'
    }
  }

  subject {Plink::RewardRecord.new(valid_params)}

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::RewardRecord.create(valid_params).should be_persisted
  end
end