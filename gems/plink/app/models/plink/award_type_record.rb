module Plink
  class AwardTypeRecord < ActiveRecord::Base
    self.table_name = 'awardTypes'

    alias_attribute :award_code, :awardCode
    alias_attribute :award_display_name, :awardDisplayName
    alias_attribute :award_type, :awardType
    alias_attribute :is_active, :isActive
    alias_attribute :email_message, :emailMessage
    alias_attribute :dollar_amount, :dollarAmount

    attr_accessible :award_code, :award_display_name, :award_type, :is_active,
        :email_message, :dollar_amount
  end
end
