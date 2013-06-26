module Plink
  class Tier

    attr_reader :dollar_award_amount, :minimum_purchase_amount

    def initialize(tier_record)
      @dollar_award_amount = tier_record.dollar_award_amount
      @minimum_purchase_amount = tier_record.minimum_purchase_amount
    end
  end
end