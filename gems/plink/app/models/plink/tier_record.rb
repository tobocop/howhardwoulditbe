module Plink
  class TierRecord < ActiveRecord::Base
    self.table_name = 'tiers'

    alias_attribute :is_active, :isActive
    alias_attribute :start_date, :beginDate

    attr_accessible :start_date, :end_date, :dollar_award_amount, :minimum_purchase_amount, :offers_virtual_currency_id


    def end_date=(date)
      self.endDate = date
    end

    def dollar_award_amount=(amount)
      self.dollarAwardAmount = amount
    end

    def dollar_award_amount
      self.dollarAwardAmount
    end

    def minimum_purchase_amount=(amount)
      self.minimumPurchaseAmount = amount
    end

    def minimum_purchase_amount
      self.minimumPurchaseAmount
    end

    def offers_virtual_currency_id=(id)
      self.offersVirtualCurrencyID = id
    end
  end
end