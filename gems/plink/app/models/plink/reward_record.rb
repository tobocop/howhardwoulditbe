module Plink
  class RewardRecord < ActiveRecord::Base
    self.table_name = 'loot'

    include Plink::LegacyTimestamps

    alias_attribute :award_code, :awardCode

    attr_accessible :award_code, :name

    has_many :amounts, class_name: 'Plink::RewardAmountRecord', foreign_key: 'lootID'

  end
end