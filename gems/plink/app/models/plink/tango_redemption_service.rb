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
      redemption_record = nil

      begin
        redemption_record = Plink::RedemptionRecord.create(attributes)
        delivery_status = deliver_card

        if delivery_status.present? && delivery_status.successful?
          confirm_redemption(redemption_record)
          redemption_record
        else
          cancel_redemption(redemption_record) if redemption_record.present? && delivery_status.present?
          raise UnsuccessfulResponseFromTangoError, "#{delivery_status.to_s}"
        end
      rescue Exception
        Plink::TangoRedemptionShutoffService.halt_redemptions unless delivery_status.present?
        ::Exceptional::Catcher.handle(
          raise $!, "#{exception_text} #{$!}", $!.backtrace
        )
      end
    end

    class UnsuccessfulResponseFromTangoError < StandardError;
    end

  private

    attr_reader :award_code, :dollar_award_amount, :email, :first_name, :gift_message, :reward_id, :reward_name, :user_id

    def attributes
      {
          dollar_award_amount: dollar_award_amount,
          reward_id: reward_id,
          user_id: user_id,
          is_pending: false,
          sent_on: Time.zone.now,
          tango_confirmed: false
      }
    end

    def cancel_redemption(redemption_record)
      redemption_record.update_attributes(
        is_active: false,
        tango_tracking_id: @tango_tracking_id
      )
    end

    def confirm_redemption(redemption_record)
      redemption_record.update_attributes(
        tango_confirmed: true,
        tango_tracking_id: @tango_tracking_id
      )
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
      @tango_tracking_id = service.tracking_record.tango_tracking_id
      service.purchase
    end

    def exception_text
      "Tango Card exception for user_id: #{user_id}, dollar_award_amount: #{dollar_award_amount}, reward_id: #{reward_id}\n"
    end
  end
end
