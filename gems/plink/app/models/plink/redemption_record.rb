module Plink
  class RedemptionRecord < ActiveRecord::Base
    self.table_name = 'redemptions'

    include Plink::LegacyTimestamps

    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :reward_id, :lootID
    alias_attribute :user_id, :userID
    alias_attribute :is_pending, :isPending
    alias_attribute :is_active, :isActive


    attr_accessible :dollar_award_amount, :reward_id, :user_id, :is_pending, :is_active
  end
end