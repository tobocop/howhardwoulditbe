module Plink
  class TangoRedemptionService

    def initialize(args = {})
      @award_code = args.fetch(:award_code)
      @reward_name = args.fetch(:reward_name)
      @dollar_award_amount = args.fetch(:dollar_award_amount)
      @reward_id = args.fetch(:reward_id)
      @user_id = args.fetch(:user_id)
      @first_name = args.fetch(:first_name)
      @email = args.fetch(:email)
    end

    def redeem
      if deliver_card.successful?
        Plink::RedemptionRecord.create(attributes)
      else
        raise('Tango Redemption failed')
      end
    end

    private

    attr_reader :award_code, :reward_name, :dollar_award_amount, :reward_id, :user_id, :first_name, :email

    def attributes
      {
          dollar_award_amount: dollar_award_amount,
          reward_id: reward_id,
          user_id: user_id,
          is_pending: false,
          sent_on: Time.now
      }
    end

    def card_service
      Tango::CardService.new(Tango::Config.instance)
    end

    def deliver_card
      card_service.purchase(
          card_sku: award_code,
          card_value: dollar_award_amount * 100,
          tango_sends_email: true,
          recipient_name: first_name,
          recipient_email: email,
          gift_message: "Here's your #{reward_name}",
          gift_from: 'Plink'
      )
    end
  end
end