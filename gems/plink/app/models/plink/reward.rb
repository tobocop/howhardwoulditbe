module Plink
  class Reward

    attr_reader :name, :amounts

    def initialize(reward_record)
      @name = reward_record.name
      @amounts = award_amounts(reward_record)
    end

    private

    def award_amounts(reward_record)
      reward_record.amounts.map {|amount_record| Plink::RewardAmount.new(amount_record)}
    end
  end
end