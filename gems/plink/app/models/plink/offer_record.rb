module Plink
  class OfferRecord < ActiveRecord::Base
    self.table_name = 'offers'

    include Plink::LegacyTimestamps

    alias_attribute :is_active, :isActive
    alias_attribute :show_on_wall, :showOnWall
    alias_attribute :end_date, :endDate
    alias_attribute :detail_text, :detailText
    alias_attribute :advertiser_name, :advertiserName
    alias_attribute :advertiser_id=, :advertiserID=
    alias_attribute :advertisers_rev_share=, :advertisersRevShare=
    alias_attribute :start_date=, :startDate=

    attr_accessible :advertiser_name, :advertiser_id, :advertisers_rev_share, :detail_text, :start_date, :is_active

    has_many :offers_virtual_currencies, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offerID'
    has_many :active_offers_virtual_currencies, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offerID', conditions: ["#{Plink::OffersVirtualCurrencyRecord.table_name}.isActive = ?", true]

    has_many :tiers, through: :offers_virtual_currencies
    has_many :live_tiers, through: :offers_virtual_currencies

    belongs_to :advertiser, class_name: 'Plink::AdvertiserRecord', foreign_key: 'advertiserID'

    def self.live_offers_for_currency(currency_id)
      joins(:active_offers_virtual_currencies).where("#{OffersVirtualCurrencyRecord.table_name}.virtualCurrencyID = ?", currency_id)
    end

    def self.for_currency_id(currency_id)
      joins(:offers_virtual_currencies).
          where("#{OffersVirtualCurrencyRecord.table_name}.virtualCurrencyID = ?", currency_id)
    end

    def self.live
      active.visible_on_wall.for_today
    end

    def self.active
      where("#{self.table_name}.isActive = ?", true)
    end

    def self.visible_on_wall
      where("#{self.table_name}.showOnWall = ?", true)
    end

    def self.for_today
      where("#{self.table_name}.startDate <= ? AND #{self.table_name}.endDate >= ?", Date.today, Date.today)
    end
  end
end