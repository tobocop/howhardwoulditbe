module Plink
  class RewardAmountRecord < ActiveRecord::Base

    self.table_name = 'lootAmounts'

    include Plink::LegacyTimestamps

    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :is_active, :isActive
    alias_attribute :reward_id, :lootID

    attr_accessible :dollar_award_amount, :is_active, :reward_id

  end
end