require 'spec_helper'

describe Plink::TangoTrackingRecord do

  let(:valid_params) {
    {
      user_id: 1,
      loot_id: 1,
      card_sku: 'comicsans',
      card_value: 10.00,
      recipient_name: 'Withakay Hicksville',
      recipient_email: 'fontboy@example.com',
      sent_to_tango_on: 1.hour.ago,
      response_from_tango_on: 10.minutes.ago,
      response_type: 'SUCCESS',
      reference_order_id: '113-083455456-28',
      card_token: '521e2ff4e536f9.10721055',
      card_number: 'V332-AM0ABN-WYZR',
      card_pin: 'wingdings'
    }
  }

  subject { Plink::TangoTrackingRecord.new(valid_params) }

  it 'can be persisted' do
    Plink::TangoTrackingRecord.create(valid_params).should be_persisted
  end

end
