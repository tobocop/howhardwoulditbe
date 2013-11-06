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

  let(:current_time) { ActiveSupport::TimeZone['MST'].now }

  let(:redemption_params) {
    {
      dollar_award_amount: 5,
      reward_id: 2,
      user_id: 2,
      is_pending: false,
      sent_on: current_time,
      tango_confirmed: false
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

  let(:redemption_successful_update_params) {
    {
      tango_confirmed: true,
      tango_tracking_id: 88897
    }
  }

  let(:redemption_unsuccessful_update_params) {
    {
      is_active: false,
      tango_tracking_id: 88570
    }
  }

  let(:parser_exception_text) { "Tango Card exception for user_id: 2, dollar_award_amount: 5, reward_id: 2\n some text" }
  let(:unsuccessful_exception_text) { "Tango Card exception for user_id: 2, dollar_award_amount: 5, reward_id: 2\n some text" }
  let(:unsuccessful_call_update_params) { { response_from_tango_on: current_time, response_type: 'INS_FUNDS' } }

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

  it 'creates and correctly updates a redemption record if the card purchase is successful' do
    Time.zone.stub(:now).and_return { current_time }
    tango_response = double(successful?: true)
    Plink::TangoTrackingService.any_instance.stub(:purchase) { tango_response }
    Tango::CardService.any_instance.stub(:purchase) { tango_successful_response_params }
    Plink::TangoTrackingRecord.any_instance.stub(:tango_tracking_id) { 88897 }
    redemption_service = Plink::TangoRedemptionService.new(valid_params)

    Plink::RedemptionRecord.should_receive(:create).with(redemption_params).and_call_original
    Plink::RedemptionRecord.any_instance.should_receive(:update_attributes).with(redemption_successful_update_params).and_call_original

    redemption_service.redeem
  end

  it 'creates and correctly updates a redemption record if the card purchase is unsuccessful' do
    Time.zone.stub(:now).and_return { current_time }
    tango_response = double(successful?: false)
    Plink::TangoTrackingService.any_instance.stub(:purchase) { tango_response }
    Tango::CardService.any_instance.stub(:purchase) { tango_failed_response_params }
    Plink::TangoTrackingRecord.any_instance.stub(:tango_tracking_id) { 88570 }
    redemption_service = Plink::TangoRedemptionService.new(valid_params)

    Plink::RedemptionRecord.should_receive(:create).with(redemption_params).and_call_original
    Plink::RedemptionRecord.any_instance.should_receive(:update_attributes).with(redemption_unsuccessful_update_params).and_call_original

    expect { redemption_service.redeem }.to raise_error()
  end

end
