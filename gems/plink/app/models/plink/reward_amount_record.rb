module Plink
  class RewardAmountRecord < ActiveRecord::Base

    self.table_name = 'lootAmounts'
    self.primary_key = 'lootAmountID'

    include Plink::LegacyTimestamps

    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :is_active, :isActive
    alias_attribute :reward_id, :lootID

    attr_accessible :dollar_award_amount, :is_active, :reward_id

    belongs_to :reward_record, class_name: 'Plink::RewardRecord', foreign_key: 'lootID'
  end
end
