require 'spec_helper'

describe Plink::FreeAwardRecord do
  let(:valid_params) {
    {
        award_type_id: 1,
        currency_award_amount: 100,
        dollar_award_amount: 1,
        user_id: 1,
        is_active: true,
        users_virtual_currency_id: 1,
        virtual_currency_id: 1,
        is_successful: true,
        is_notification_successful: true
    }
  }

  subject { Plink::FreeAwardRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::FreeAwardRecord.create(valid_params).should be_persisted
  end

end