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

    belongs_to :offers_virtual_currency, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offersVirtualCurrencyID'

    after_initialize :init

    scope :tiers_for_advertiser, ->(advertiser_id) {
      select('tiers.*')
      .joins(:offers_virtual_currency)
      .joins('INNER JOIN offers ON offers.offerID = offersVirtualCurrencies.offerID')
      .joins('INNER JOIN advertisers ON advertisers.advertiserID = offers.advertiserID')
      .where('advertisers.advertiserID = ?', advertiser_id)
    }

    scope :tiers_for_virtual_currency, ->(virtual_currency_id) {
      select('tiers.*')
      .joins(:offers_virtual_currency)
      .joins('INNER JOIN offers ON offers.offerID = offersVirtualCurrencies.offerID')
      .where('virtualCurrencyID = ?', virtual_currency_id)
    }

    scope :tiers_for_advertiser_and_virtual_currency, ->(advertiser_id, virtual_currency_id) {
      tiers_for_advertiser(advertiser_id)
      .tiers_for_virtual_currency(virtual_currency_id)
    }

    def init
      self.minimum_purchase_amount ||= 0
    end

  end
end
