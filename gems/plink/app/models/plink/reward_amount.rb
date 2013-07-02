module Plink
  class RewardAmount

    attr_reader :dollar_award_amount

    def initialize(reward_amount_record)
      @dollar_award_amount = reward_amount_record.dollar_award_amount
    end
  end
end