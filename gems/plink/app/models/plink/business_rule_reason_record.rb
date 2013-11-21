module Plink
  class BusinessRuleReasonRecord < ActiveRecord::Base
    self.table_name = 'business_rule_reasons'

    attr_accessible :description, :is_active, :name
  end
end
