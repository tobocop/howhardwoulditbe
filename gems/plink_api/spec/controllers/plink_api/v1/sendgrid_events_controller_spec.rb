require 'spec_helper'

describe PlinkApi::V1::SendgridEventsController do
  describe 'POST create' do
    let(:event_processor) { double(PlinkApi::V1::SendgridEventsProcessingService, process: true) }

    context 'when successful' do
      before do
        PlinkApi::V1::SendgridEventsProcessingService.stub(:new).and_return(event_processor)
        event_processor.stub(:process).and_return(true)
      end

      it 'responds with a 200' do
        post :create, _json: 'valid json'

        response.status.should == 200
      end
    end

    context 'when unsuccessful' do
      before do
        PlinkApi::V1::SendgridEventsProcessingService.stub(:new).and_return(event_processor)
        event_processor.stub(:process).and_raise('some error')
      end

      it 'responds with a 400' do
        ::Exceptional::Catcher.stub(:handle)

        post :create, _json: 'invalid json'

        response.status.should == 400
      end

      it 'should log an error to Exceptional' do
        ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
          exception.should respond_to(:backtrace)
          message.should == 'Sendgrid Event Processing Failed'
        end

        post :create, _json: 'invalid json'
      end
    end
  end
end
