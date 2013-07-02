require 'spec_helper'

describe Plink::AwardType do

  let(:valid_params) {
    {
      award_code: 'ASD',
      award_display_name: 'Awesome Award',
      award_type: 'cool',
      is_active: true
    }
  }

  subject { Plink::AwardType.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::AwardType.create(valid_params).should be_persisted
  end
end