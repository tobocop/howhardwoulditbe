module Plink
  class TangoRedemptionService

    require 'exceptional'

    GIFT_FROM = 'Plink'
    PLINK_POINTS_EXCHANGE_RATE = 100

    def initialize(args = {})
      @award_code = args.fetch(:award_code)
      @reward_name = args.fetch(:reward_name)
      @dollar_award_amount = args.fetch(:dollar_award_amount)
      @reward_id = args.fetch(:reward_id)
      @user_id = args.fetch(:user_id)
      @first_name = args.fetch(:first_name)
      @email = args.fetch(:email)

      @gift_message = "Here's your #{@reward_name}"
    end

    def redeem
      delivery_status = nil
      begin
        delivery_status = deliver_card
        Plink::RedemptionRecord.create(attributes) if delivery_status.present? && delivery_status.successful?
      rescue Exception => e
        Plink::TangoRedemptionShutoffService.halt_redemptions
        ::Exceptional::Catcher.handle(
          raise $!, "#{exception_text} #{$!}", $!.backtrace
        )
      end

    end

    private

    attr_reader :award_code, :dollar_award_amount, :email, :first_name, :gift_message, :reward_id, :reward_name, :user_id

    def attributes
      {
          dollar_award_amount: dollar_award_amount,
          reward_id: reward_id,
          user_id: user_id,
          is_pending: false,
          sent_on: Time.zone.now
      }
    end

    def tango_tracking_service
      Plink::TangoTrackingService
    end

    def deliver_card
      service = tango_tracking_service.new(
        award_code: award_code,
        card_value: (dollar_award_amount * PLINK_POINTS_EXCHANGE_RATE),
        dollar_award_amount: dollar_award_amount,
        gift_message: gift_message,
        gift_from: GIFT_FROM,
        recipient_email: email,
        recipient_name: first_name,
        reward_id: reward_id,
        tango_sends_email: true,
        user_id: user_id
      )
      service.purchase

    end

    def exception_text
      "Tango Card exception for user_id: #{user_id}, dollar_award_amount: #{dollar_award_amount}, reward_id: #{reward_id}\n"
    end
  end
end
