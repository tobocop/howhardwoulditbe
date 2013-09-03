require 'spec_helper'

describe Plink::TangoRedemptionService do

  let(:valid_params) do
    {
      award_code: 'asd',
      reward_name: 'Fake - card',
      dollar_award_amount: 5,
      reward_id: 2,
      user_id: 2,
      first_name: 'test_name',
      email: 'test@example.com'
    }
  end

  it 'raises if the response is not successful?' do
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    fake_purchase_response = double(:fake_purchase_response, successful?: false)
    redemption_service.stub(:card_service).and_return(double(:card_service, purchase: fake_purchase_response))

    expect {
      redemption_service.redeem
    }.to raise_exception('Tango Redemption failed')
  end
end