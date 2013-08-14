module Plink
  class TierRecord < ActiveRecord::Base
    self.table_name = 'tiers'

    alias_attribute :is_active, :isActive
    alias_attribute :dollar_award_amount, :dollarAwardAmount
    alias_attribute :minimum_purchase_amount, :minimumPurchaseAmount
    alias_attribute :start_date, :beginDate
    alias_attribute :end_date, :endDate
    alias_attribute :offers_virtual_currency_id, :offersVirtualCurrencyID
    alias_attribute :percent_award_amount, :percentAwardAmount

    attr_accessible :start_date, :end_date, :dollar_award_amount, :minimum_purchase_amount, :offers_virtual_currency_id, :percent_award_amount

    after_initialize :init

    def init
      self.minimum_purchase_amount ||= 0
    end
  end
end
