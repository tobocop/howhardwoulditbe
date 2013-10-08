module Plink
  class RewardAmount

    attr_reader :id, :dollar_award_amount

    MAXIMUM_REDEMPTION_VALUE = 25

    def initialize(reward_amount_record)
      @id = reward_amount_record.id
      @dollar_award_amount = reward_amount_record.dollar_award_amount
    end
  end
end
