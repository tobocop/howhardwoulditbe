module Plink

  class TangoTrackingService

    attr_reader :award_code, :card_value, :gift_from, :gift_message, :recipient_email, :recipient_name, :reward_id, :tango_sends_email, :tracking_record, :user_id

    def initialize(options={})
      @award_code = options.fetch(:award_code)
      @card_value = options.fetch(:card_value)
      @recipient_email = options.fetch(:recipient_email)
      @recipient_name = options.fetch(:recipient_name)
      @reward_id = options.fetch(:reward_id)
      @tango_sends_email = options.fetch(:tango_sends_email)
      @user_id = options.fetch(:user_id)
      @gift_message = options.fetch(:gift_message)
      @gift_from = options.fetch(:gift_from)

      @tracking_record = tango_tracking_record.new(
        card_sku: @award_code,
        card_value: @card_value,
        loot_id: @reward_id,
        recipient_email: @recipient_email,
        recipient_name: @recipient_name,
        sent_to_tango_on: DateTime.now,
        user_id: @user_id
      )
      @tracking_record.save!
    end

    def purchase
      track_purchase(purchase_request)
    end

    private

    def track_purchase(tango_response)

      @tracking_record.response_type = tango_response.response_type

      if tango_response.response_type == 'SUCCESS'
        @tracking_record.reference_order_id = tango_response.reference_order_id
        @tracking_record.card_token = tango_response.card_token
        @tracking_record.card_number = tango_response.card_number
      elsif tango_response.response_type.blank?
        @tracking_record.response_type = 'EMPTY_OR_UNPARSEABLE_RESPONSE'
      end

      @tracking_record.save!
      tango_response
    end


    def tango_tracking_record
      Plink::TangoTrackingRecord
    end

    def tango_card_service
      Tango::CardService.new(Tango::Config.instance)
    end

    def purchase_request
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