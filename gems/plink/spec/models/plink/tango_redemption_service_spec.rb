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

  let(:tango_failed_response_params) {
    {
      response_type: 'INS_FUNDS',
      successful?: false
    }
  }

  let(:tango_successful_response_params) {
    {
      response_type: 'SUCCESS',
      reference_order_id: '113-094091226-04',
      card_token: '521008c3bfb3a8.656892554',
      card_number: 'VZ5T-0RL34L-YYVD',
      successful?: true
    }
  }

  it 'raises if the response is not successful?' do
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    Plink::TangoTrackingService.any_instance.stub(:purchase).and_return(double(tango_failed_response_params))

    expect {
      redemption_service.redeem
    }.to raise_exception('Tango Redemption failed')
  end

  it 'returns a Redemption Record if the response is successful?' do
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    Plink::TangoTrackingService.any_instance.stub(:purchase).and_return(double(tango_successful_response_params))

    redemption_service.redeem.should be_instance_of Plink::RedemptionRecord

  end

end