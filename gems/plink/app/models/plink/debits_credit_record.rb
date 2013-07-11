module Plink
  class DebitsCreditRecord < ActiveRecord::Base
    self.table_name = 'vw_debitsCredits'

    alias_attribute :award_display_name, :awardDisplayName
    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :currency_award_amount, :currencyAwardAmount
    alias_attribute :display_currency_name, :displayCurrencyName
    alias_attribute :award_type, :awardType

    TYPES = {
      :qualified => 'qualified',
      :non_qualified => 'Non-qualifying',
      :redemption => 'Loot'
    }

    def self.qualified_type
      TYPES[:qualified]
    end

    def self.non_qualified_type
      TYPES[:non_qualified]
    end

    def self.redemption_type
      TYPES[:redemption]
    end

    def is_reward
      isReward == 1 ? true : false
    end
  end
end