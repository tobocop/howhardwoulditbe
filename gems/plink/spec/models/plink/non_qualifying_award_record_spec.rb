require 'spec_helper'

describe Plink::NonQualifyingAwardRecord do
  let(:valid_params) {
    {
      currency_award_amount: 13,
      dollar_award_amount: 0.13,
      user_id: 13,
      users_virtual_currency_id: 2,
      virtual_currency_id: 2,
      advertiser_id: 23,
      is_active: true,
      is_successful: true,
      is_notification_successful: true
    }
  }

  subject { new_non_qualifying_award(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::NonQualifyingAwardRecord.create(valid_params).should be_persisted
  end
end
