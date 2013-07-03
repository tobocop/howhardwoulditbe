module Plink
  class RewardAmount

    attr_reader :id, :dollar_award_amount

    def initialize(reward_amount_record)
      @id = reward_amount_record.id
      @dollar_award_amount = reward_amount_record.dollar_award_amount
    end
  end
end