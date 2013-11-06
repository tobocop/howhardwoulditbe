require 'spec_helper'

describe Plink::TangoTrackingService do

  let(:current_time) { ActiveSupport::TimeZone['MST'].now }

  describe '#new' do

    subject(:tracking_service) { Plink::TangoTrackingService }
    let(:award_code) { 'fonttard' }
    let(:card_value) { 100 * dollar_award_amount }
    let(:dollar_award_amount) { 10 }
    let(:gift_message) { "Here's your #{reward_name}" }
    let(:gift_from) { 'Plink' }
    let(:recipient_name) { 'Withakay' }
    let(:recipient_email) { 'KrisLovesComicSans@example.com' }
    let(:reward_name) { 'HicksvilleBucks' }
    let(:reward_id) { 7 }
    let(:tango_sends_email) { true }
    let(:user_id) { 5 }

    it 'sets the initial tracking parameters' do

      Time.zone.stub(:now).and_return { current_time }

      Plink::TangoTrackingRecord.stub(:save!).and_return(true)
      Plink::TangoTrackingRecord.should_receive(:new).with(
        card_sku: award_code,
        card_value: dollar_award_amount,
        loot_id: reward_id,
        recipient_email: recipient_email,
        recipient_name: recipient_name,
        sent_to_tango_on: current_time,
        user_id: user_id
      ).and_call_original

      subject.new(
        award_code: award_code,
        card_value: card_value,
        dollar_award_amount: dollar_award_amount,
        gift_from: gift_from,
        gift_message: gift_message,
        recipient_email: recipient_email,
        recipient_name: recipient_name,
        reward_id: reward_id,
        reward_name: reward_name,
        tango_sends_email: tango_sends_email,
        user_id: user_id
      )

    end

  end

  describe '#purchase' do

    subject(:tracking_service) { Plink::TangoTrackingService }

    context 'when successful' do

      let(:tango_response_params) {
        {
          response_type: 'SUCCESS',
          reference_order_id: '113-094091226-04',
          card_token: '521008c3bfb3a8.656892554',
          card_number: 'VZ5T-0RL34L-YYVD',
          successful?: true,
          raw_response: 'raw_response'
        }
      }

      let(:tango_response_mock) { double(tango_response_params) }
      subject (:tracking_service) { Plink::TangoTrackingService.new(
        award_code: 'fontphoria',
        card_value: 1000,
        dollar_award_amount: 1000,
        gift_from: 'FontHeaven',
        gift_message: "Here's your FontBucks",
        recipient_email: 'KrisAlsoLovesHelvetica@example.com',
        recipient_name: 'Krithy',
        reward_id: 9,
        reward_name: 'FontBucks',
        tango_sends_email: true,
        user_id: 13
      ) }

      it 'updates the initial tracking parameters with data returned from the call' do
        Time.zone.stub(:now).and_return { current_time }
        Tango::CardService.any_instance.stub(:purchase) { tango_response_mock }
        Plink::TangoTrackingRecord.any_instance.stub(:save!).and_return(true)

        subject.purchase

        subject.tracking_record.response_type.should == 'SUCCESS'
        subject.tracking_record.reference_order_id.should == '113-094091226-04'
        subject.tracking_record.card_token.should == '521008c3bfb3a8.656892554'
        subject.tracking_record.card_number.should == 'VZ5T-0RL34L-YYVD'
        subject.tracking_record.response_from_tango_on.should == current_time
        subject.tracking_record.raw_response.should == 'raw_response'
      end

    end

    context 'when a failure occurs' do

      let(:tango_response_params) {
        {
          response_type: 'INS_FUNDS',
          successful?: false,
          raw_response: 'raw_response'
        }
      }

      let(:tango_response_mock) { double(tango_response_params) }
      subject (:tracking_service) { Plink::TangoTrackingService.new(
        award_code: 'fontphobia',
        card_value: 1000,
        dollar_award_amount: 10,
        gift_from: 'Fontastic',
        gift_message: "Here's your FontShekels",
        recipient_email: 'fontweasel@example.com',
        recipient_name: 'Krisp',
        reward_id: 9,
        reward_name: 'FontShekels',
        tango_sends_email: true,
        user_id: 13
      ) }

      it 'updates the tracking data if a failure occurs' do
        Tango::CardService.any_instance.stub(:purchase) { tango_response_mock }
        Plink::TangoTrackingRecord.any_instance.stub(:save!).and_return(true)
        subject.purchase

        subject.tracking_record.response_type.should == 'INS_FUNDS'
        subject.tracking_record.raw_response.should == 'raw_response'
      end
    end

  end
end
