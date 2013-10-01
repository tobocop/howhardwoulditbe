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
    alias_attribute :advertisers_rev_share, :advertisersRevShare
    alias_attribute :start_date=, :startDate=

    attr_accessible :advertiser_name, :advertiser_id, :advertisers_rev_share, :detail_text, :end_date, :is_active, :start_date

    has_many :offers_virtual_currencies, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offerID'
    has_many :active_offers_virtual_currencies, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offerID', conditions: ["#{Plink::OffersVirtualCurrencyRecord.table_name}.isActive = ?", true]
    has_many :active_virtual_currencies, class_name: 'Plink::VirtualCurrency', through: :active_offers_virtual_currencies, source: :virtual_currency

    has_many :tiers, through: :offers_virtual_currencies

    has_many :live_tiers, through: :offers_virtual_currencies do
      def for_virtual_currency(virtual_currency_id)
        where("virtualCurrencyID = ?", virtual_currency_id)
      end
    end

    belongs_to :advertiser, class_name: 'Plink::AdvertiserRecord', foreign_key: 'advertiserID'

    scope :live_non_excluded_offers_for_currency, ->(wallet_id, currency_id) {
      live_offers_for_currency(currency_id)
      .non_excluded_offers(wallet_id)
    }

    scope :non_excluded_offers, ->(wallet_id) {
      offer_exclusions = Plink::OfferExclusionRecord.table_name
      joins("
        LEFT JOIN #{offer_exclusions} ON #{offer_exclusions}.offerID = #{self.table_name}.offerID
          AND #{offer_exclusions}.walletID = #{sanitize(wallet_id)}")
      .where("#{offer_exclusions}.offerID IS NULL")
    }

    scope :live_offers_for_currency, ->(currency_id) {
      live
      .includes(:active_offers_virtual_currencies)
      .where("#{OffersVirtualCurrencyRecord.table_name}.virtualCurrencyID = ?", currency_id)
      .order("#{table_name}.is_new DESC, #{table_name}.created DESC")
    }

    def self.in_wallet(wallet_id)
      joins(:offers_virtual_currencies)
      .joins("JOIN #{WalletItemRecord.table_name} ON #{OffersVirtualCurrencyRecord.table_name}.offersVirtualCurrencyID = #{WalletItemRecord.table_name}.offersVirtualCurrencyID")
      .where("#{WalletItemRecord.table_name}.walletID = ?", wallet_id)
    end

    def self.for_currency_id(currency_id)
      joins(:offers_virtual_currencies).
          where("#{OffersVirtualCurrencyRecord.table_name}.virtualCurrencyID = ?", currency_id)
    end

    def self.live
      active.visible_on_wall.for_today
    end

    def self.live_only(id)
      live.find(id)
    end

    def self.active
      where("#{self.table_name}.isActive = ?", true)
    end

    def self.visible_on_wall
      where("#{self.table_name}.showOnWall = ?", true)
    end

    def self.for_today
      where("#{self.table_name}.startDate <= ? AND #{self.table_name}.endDate >= ?", Time.zone.today, Time.zone.today)
    end
  end
end
