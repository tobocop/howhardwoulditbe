require 'spec_helper'

describe Plink::AwardType do

  let(:valid_params) {
    {
      award_code: 'ASD',
      award_display_name: 'Awesome Award',
      award_type: 'cool',
      is_active: true,
      email_message: 'message'
    }
  }

  subject { Plink::AwardType.new(valid_params) }

  it 'can be persisted' do
    Plink::AwardType.create(valid_params).should be_persisted
  end
end