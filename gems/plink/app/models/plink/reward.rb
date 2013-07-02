module Plink
  class Reward

    attr_reader :name, :amounts

    def initialize(reward_record, amount_records)
      @name = reward_record.name
      @amounts = award_amounts(amount_records)
    end

    private

    def award_amounts(amount_records)
      amount_records.map {|amount_record| Plink::RewardAmount.new(amount_record)}
    end
  end
end