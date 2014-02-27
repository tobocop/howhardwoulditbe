module PlinkApi::V1
  class SendgridEventsProcessingService
    EVENTS_TO_PROCESS = ['dropped', 'bounce', 'spamreport']

    attr_accessor :events

    def initialize(events)
      @events = JSON.parse(events, symbolize_names: true)
    end

    def process
      preferences = {is_subscribed: '0', daily_contest_reminder: '0'}
      user_service = Plink::UserService.new(true)

      @events.each do |event|
        if EVENTS_TO_PROCESS.include? event[:event]
          user = user_service.find_by_email(event[:email])
          user_service.update_subscription_preferences(user.id, preferences)
        end
      end

      true
    end
  end
end
