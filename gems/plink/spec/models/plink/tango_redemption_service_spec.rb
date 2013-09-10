require 'spec_helper'

describe Plink::TangoRedemptionService do

  let(:valid_params) {
    {
      award_code: 'asd',
      reward_name: 'Fake - card',
      dollar_award_amount: 5,
      reward_id: 2,
      user_id: 2,
      first_name: 'test_name',
      email: 'test@example.com'
    }
  }

  let(:tango_response_params) {
    {
      response_type: 'INS_FUNDS',
      successful?: false
    }
  }

  it 'raises if the response is not successful?' do
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    Plink::TangoTrackingService.any_instance.stub(:purchase).and_return(double(tango_response_params))

    expect {
      redemption_service.redeem
    }.to raise_exception('Tango Redemption failed')
  end
end