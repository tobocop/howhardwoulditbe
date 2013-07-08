module Plink
  class PendingRedemptionService

    def initialize(args = {})
      @dollar_award_amount = args.fetch(:dollar_award_amount)
      @reward_id = args.fetch(:reward_id)
      @user_id = args.fetch(:user_id)
    end

    def redeem
      Plink::RedemptionRecord.create(attributes)
    end

    private

    attr_reader :dollar_award_amount, :reward_id, :user_id

    def attributes
      {
          dollar_award_amount: dollar_award_amount,
          reward_id: reward_id,
          user_id: user_id,
          is_pending: true
      }
    end

  end
end