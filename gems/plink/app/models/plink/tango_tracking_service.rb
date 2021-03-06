module Plink

  class TangoTrackingService

    attr_reader :award_code, :card_value, :gift_from, :gift_message, :recipient_email, :recipient_name, :reward_id,
                :tango_sends_email, :tracking_record, :user_id

    def initialize(options={})
      @award_code = options.fetch(:award_code)
      @card_value = options.fetch(:card_value)
      @dollar_award_amount = options.fetch(:dollar_award_amount)
      @recipient_email = options.fetch(:recipient_email)
      @recipient_name = options.fetch(:recipient_name)
      @reward_id = options.fetch(:reward_id)
      @tango_sends_email = options.fetch(:tango_sends_email)
      @user_id = options.fetch(:user_id)
      @gift_message = options.fetch(:gift_message)
      @gift_from = options.fetch(:gift_from)

      @tracking_record = tango_tracking_record.new(
        card_sku: @award_code,
        card_value: @dollar_award_amount,
        loot_id: @reward_id,
        recipient_email: @recipient_email,
        recipient_name: @recipient_name,
        sent_to_tango_on: Time.zone.now,
        user_id: @user_id
      )
      @tracking_record.save!
    end

    def purchase

      begin
        tango_response = request_card_from_tango
      rescue Exception => e
        @tracking_record.response_type = 'TANGO_UNREACHABLE_OR_EMPTY_RESPONSE'
        @tracking_record.raw_response = "response was: '#{tango_response}', error: #{e.message}"
      else
        @tracking_record.response_type = tango_response.response_type
        @tracking_record.response_from_tango_on = Time.zone.now
        @tracking_record.raw_response = tango_response.raw_response

        if tango_response.response_type == 'SUCCESS'
          @tracking_record.reference_order_id = tango_response.reference_order_id
          @tracking_record.card_token = tango_response.card_token
          @tracking_record.card_number = tango_response.card_number
        end
      end

      @tracking_record.save!
      tango_response
    end

  private

    def tango_tracking_record
      Plink::TangoTrackingRecord
    end

    def tango_card_service
      Tango::CardService.new(Tango::Config.instance)
    end

    def request_card_from_tango
      attributes = {
        card_sku: self.award_code,
        card_value: self.card_value,
        gift_from: self.gift_from,
        gift_message: self.gift_message,
        recipient_email: self.recipient_email,
        recipient_name: self.recipient_name,
        tango_sends_email: self.tango_sends_email
      }

      tango_card_service.purchase(attributes)
    end

  end

end
