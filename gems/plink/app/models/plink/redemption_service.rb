module Plink
  class RedemptionService

    def create_pending(args)
      user_id = args.fetch(:user_id)
      reward_amount_id = args.fetch(:reward_amount_id)
      user_balance = args.fetch(:user_balance)

      reward_amount_record = RewardAmountRecord.find(reward_amount_id)

      return false if reward_amount_record.dollar_award_amount > user_balance

      RedemptionRecord.create(
          dollar_award_amount: reward_amount_record.dollar_award_amount,
          reward_id: reward_amount_record.reward_id,
          user_id: user_id,
          is_pending: true
      )
    end
  end
end