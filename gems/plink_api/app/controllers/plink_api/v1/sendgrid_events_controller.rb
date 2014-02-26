module PlinkApi::V1
  class SendgridEventsController < PlinkApi::ApplicationController
    EVENTS_TO_PROCESS = ['dropped', 'bounce', 'spamreport']

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
        events_json = JSON.parse(events, symbolize_names: true)
        preferences = {is_subscribed: '0', daily_contest_reminder: '0'}
        user_service = Plink::UserService.new(true)

        events_json.each do |event|
          if EVENTS_TO_PROCESS.include? event[:event]
            user = user_service.find_by_email(event[:email])
            user_service.update_subscription_preferences(user.id, preferences)
          end
        end

        true
      rescue
        ::Exceptional::Catcher.handle($!, 'Sendgrid Event Processing Failed')

        false
      end
    end
  end
end