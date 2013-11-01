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

  let(:current_time) { Date.current }

  let(:redemption_params) {
    {
      dollar_award_amount: 5,
      reward_id: 2,
      user_id: 2,
      is_pending: false,
      sent_on: current_time
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

  let(:parser_exception_text) { "Tango Card exception for user_id: 2, dollar_award_amount: 5, reward_id: 2\n some text" }
  let(:unsuccessful_exception_text) { "Tango Card exception for user_id: 2, dollar_award_amount: 5, reward_id: 2\n some text" }

  it 'adds information to the exception if an exception is raised' do
    Plink::TangoTrackingService.any_instance.stub(:purchase).and_raise(JSON::ParserError.new('some text'))
    redemption_service = Plink::TangoRedemptionService.new(valid_params)

    expect {
      redemption_service.redeem
    }.to raise_exception(JSON::ParserError, parser_exception_text)
  end

  it 'calls the Tango Redemption Shutoff service if an exception is raised' do
    Plink::TangoTrackingService.any_instance.stub(:purchase).and_raise(JSON::ParserError.new('some text'))
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    Plink::TangoRedemptionShutoffService.should_receive(:halt_redemptions)

    expect { redemption_service.redeem }.to raise_error()
  end

  it 'adds information to the exception if the response is not successful' do
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    Plink::TangoTrackingService.any_instance.stub(:purchase).and_raise(Tango::PurchaseCardResponse::OtherError, 'some text')

    expect {
      redemption_service.redeem
    }.to raise_exception(Tango::PurchaseCardResponse::OtherError, unsuccessful_exception_text)
  end

  it 'calls the Tango Redemption Shutoff service if the response is not successful' do
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    Plink::TangoTrackingService.any_instance.stub(:purchase).and_raise(Tango::PurchaseCardResponse::OtherError, 'some text')
    Plink::TangoRedemptionShutoffService.should_receive(:halt_redemptions)

    expect { redemption_service.redeem }.to raise_error()
  end

  it 'creates a redemption record if the card purchase is successful?' do
    tango_response = double(successful?: true)
    Plink::TangoTrackingService.any_instance.stub(:purchase) { tango_response }
    Tango::CardService.any_instance.stub(:purchase) { tango_successful_response_params }
    tango_response = double(successful?: true)
    redemption_service = Plink::TangoRedemptionService.new(valid_params)
    Time.stub(:zone).and_return(double(now: current_time))

    Plink::RedemptionRecord.should_receive(:create).with(redemption_params)

    redemption_service.redeem
  end

end
