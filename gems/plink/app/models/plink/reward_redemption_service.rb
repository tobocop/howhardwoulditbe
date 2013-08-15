module Plink
  class RewardRedemptionService

    def initialize(args = {})
      @reward_amount_id = args.fetch(:reward_amount_id)
      @user_balance = args.fetch(:user_balance)
      @user_id = args.fetch(:user_id)
      @first_name = args.fetch(:first_name)
      @email = args.fetch(:email)
    end

    def redeem
      return false unless user_can_afford_it? && eligible_redemption_amount?
      process!
    end

    private

    attr_reader :reward_amount_id, :user_balance, :user_id, :first_name, :email

    def process!
      redemption_service.redeem
    end

    def redemption_service
      if user_can_auto_redeem? && reward_record.is_tango
        tango_redemption_service
      else
        pending_redemption_service
      end
    end

    def user_can_afford_it?
      reward_amount_record.dollar_award_amount <= user_balance
    end

    def eligible_redemption_amount?
      reward_amount_record.dollar_award_amount <= Plink::RewardAmount::MAXIMUM_REDEMPTION_VALUE
    end

    def tango_redemption_service
      TangoRedemptionService.new(
        award_code: reward_record.award_code,
        reward_name: reward_record.name,
        dollar_award_amount: reward_amount_record.dollar_award_amount,
        reward_id: reward_record.id,
        user_id: user_id,
        first_name: first_name,
        email: email
      )
    end

    def pending_redemption_service
      PendingRedemptionService.new(
        dollar_award_amount: reward_amount_record.dollar_award_amount,
        reward_id: reward_record.id,
        user_id: user_id
      )
    end

    def reward_amount_record
      @reward_amount_record ||= RewardAmountRecord.find(reward_amount_id)
    end

    def reward_record
      @reward_record ||= RewardRecord.find(reward_amount_record.reward_id)
    end

    def user_can_auto_redeem?
      qualifying_award_record.find_successful_by_user_id(user_id).size >= 2
    end

    def qualifying_award_record
      Plink::QualifyingAwardRecord
    end
  end
end
