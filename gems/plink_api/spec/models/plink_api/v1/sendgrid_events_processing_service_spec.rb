require 'spec_helper'

describe PlinkApi::V1::SendgridEventsProcessingService do
  let(:valid_event_data) {
    '[
      {
          "email": "dropped@example.com",
          "timestamp": 1337197600,
          "smtp-id": "<4FB4041F.6080505@sendgrid.com>",
          "event": "dropped"
      },
      {
          "email": "bounced@example.com",
          "timestamp": 1337966815,
          "smtp-id": "<4FBFC0DD.5040601@sendgrid.com>",
          "category": "newuser",
          "event": "bounce"
      },
      {
          "email": "spamreport@example.com",
          "timestamp": 1337969592,
          "smtp-id": "<20120525181309.C1A9B40405B3@Example-Mac.local>",
          "event": "spamreport"
      },
      {
          "email": "processed@example.com",
          "timestamp": 1337969592,
          "smtp-id": "<20120525181309.C1A9B40405B3@Example-Mac.local>",
          "event": "processed"
      }
    ]'
  }

  describe '#initialize' do
    it 'raises an error if the passed in value is not a valid JSON struct' do
      expect{ PlinkApi::V1::SendgridEventsProcessingService.new(nil) }.to raise_error
    end

    it 'parses the events into a JSON struct and sets the events attribute' do
      event_processor = PlinkApi::V1::SendgridEventsProcessingService.new(valid_event_data)

      event_processor.events.should == JSON.parse(valid_event_data, symbolize_names: true)
    end
  end

  describe '.process' do
    let(:user) { double(Plink::UserRecord, id: 200) }
    let(:user_service) { double(Plink::UserService, find_by_email: user, update_subscription_preferences: user) }

    subject(:event_processor) { PlinkApi::V1::SendgridEventsProcessingService.new(valid_event_data) }

    before do
      Plink::UserService.stub(:new).and_return(user_service)
    end

    it 'should return true' do
      event_processor.process.should be_true
    end

    it 'should create an unscoped instance of the Plink::UserService' do
      Plink::UserService.should_receive(:new).with(true)

      event_processor.process
    end

    it 'should find the user when the event type is dropped' do
      user_service.should_receive(:find_by_email).with('dropped@example.com')

      event_processor.process
    end

    it 'should find the user when the event type is bounce' do
      user_service.should_receive(:find_by_email).with('bounced@example.com')

      event_processor.process
    end

    it 'should find the user when the event type is spamreport' do
      user_service.should_receive(:find_by_email).with('spamreport@example.com')

      event_processor.process
    end

    it 'should skip the user when the event type is not dropped, bounce or spamreport' do
      user_service.should_not_receive(:find_by_email).with('processed@example.com')

      event_processor.process
    end

    it 'should unsubscribe the users that are found' do
      user_service.should_receive(:update_subscription_preferences).
        with(200, { is_subscribed: '0', daily_contest_reminder: '0' } ).
        exactly(3).times

      event_processor.process
    end
  end
end
