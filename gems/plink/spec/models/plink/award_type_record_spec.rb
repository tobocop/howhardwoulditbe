require 'spec_helper'

describe Plink::AwardTypeRecord do

  let(:valid_params) {
    {
      award_code: 'ASD',
      award_display_name: 'Awesome Award',
      award_type: 'cool',
      is_active: true,
      dollar_amount: 1,
      email_message: 'message'
    }
  }

  subject { Plink::AwardTypeRecord.new(valid_params) }

  it 'can be persisted' do
    Plink::AwardTypeRecord.create(valid_params).should be_persisted
  end
end
