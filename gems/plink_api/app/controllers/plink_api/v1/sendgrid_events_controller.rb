module PlinkApi::V1
  class SendgridEventsController < PlinkApi::ApplicationController
    respond_to :json

    def create
      if process_events(params[:_json])
        head :ok
      else
        head :bad_request
      end
    end

  private

    def process_events(events)
      begin
        event_processor = PlinkApi::V1::SendgridEventsProcessingService.new(events)

        event_processor.process
      rescue
        ::Exceptional::Catcher.handle($!, 'Sendgrid Event Processing Failed')

        false
      end
    end
  end
end