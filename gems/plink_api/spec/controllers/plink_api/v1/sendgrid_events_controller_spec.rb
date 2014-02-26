require 'spec_helper'

describe PlinkApi::V1::SendgridEventsController do
  describe 'POST create' do
    let(:user) { double(Plink::UserRecord, id: 200) }
    let(:user_service) { double(Plink::UserService, find_by_email: user, update_subscription_preferences: user) }

    context 'when successful' do
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

      before do
        Plink::UserService.stub(:new).and_return(user_service)
        ::Exceptional::Catcher.should_not_receive(:handle)
      end

      it 'responds with a 200' do
        post :create, _json: valid_event_data

        response.status.should == 200
      end

      it 'should create an unscoped instance of the Plink::UserService' do
        Plink::UserService.should_receive(:new).with(true)

        post :create, _json: valid_event_data
      end

      it 'should find the user when the event type is dropped' do
        user_service.should_receive(:find_by_email).with('dropped@example.com')

        post :create, _json: valid_event_data
      end

      it 'should find the user when the event type is bounce' do
        user_service.should_receive(:find_by_email).with('bounced@example.com')

        post :create, _json: valid_event_data
      end

      it 'should find the user when the event type is spamreport' do
        user_service.should_receive(:find_by_email).with('spamreport@example.com')

        post :create, _json: valid_event_data
      end

      it 'should skip the user when the event type is not dropped, bounce or spamreport' do
        user_service.should_not_receive(:find_by_email).with('processed@example.com')

        post :create, _json: valid_event_data
      end

      it 'should unsubscribe the users that are found' do
        user_service.should_receive(:update_subscription_preferences).
          with(200, { is_subscribed: '0', daily_contest_reminder: '0' } ).
          exactly(3).times

        post :create, _json: valid_event_data
      end
    end

    context 'when unsuccessful' do
      let(:invalid_event_data) {
        '[bad json]'
      }

      before do
        Plink::UserService.stub(:new).and_return(user_service)
      end

      it 'responds with a 400' do
        ::Exceptional::Catcher.stub(:handle)

        post :create, _json: invalid_event_data

        response.status.should == 400
      end

      it 'should log an error to Exceptional' do
        ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
          exception.should respond_to(:backtrace)
          message.should == 'Sendgrid Event Processing Failed'
        end

        post :create, _json: invalid_event_data
      end
    end
  end
end
