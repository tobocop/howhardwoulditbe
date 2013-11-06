module Plink
  class RedemptionRecord < ActiveRecord::Base
    self.table_name = 'redemptions'

    include Plink::LegacyTimestamps

    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :is_active, :isActive
    alias_attribute :is_pending, :isPending
    alias_attribute :reward_id, :lootID
    alias_attribute :sent_on, :sentOn
    alias_attribute :user_id, :userID

    attr_accessible :dollar_award_amount, :is_active, :is_pending, :reward_id, :sent_on, :tango_confirmed,
      :tango_tracking_id, :user_id
  end
end