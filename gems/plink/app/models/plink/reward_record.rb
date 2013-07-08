module Plink
  class RewardRecord < ActiveRecord::Base
    self.table_name = 'loot'

    include Plink::LegacyTimestamps

    alias_attribute :award_code, :awardCode
    alias_attribute :is_active, :isActive
    alias_attribute :is_tango, :isTangoRedemption

    attr_accessible :award_code, :name, :is_active, :is_tango

    has_many :amounts, class_name: 'Plink::RewardAmountRecord', foreign_key: 'lootID'
    has_many :live_amounts, class_name: 'Plink::RewardAmountRecord', foreign_key: 'lootID', conditions: ["#{Plink::RewardAmountRecord.table_name}.isActive = ?", true]

    def self.live
      where("#{table_name}.isActive = ?", true)
    end

  end
end