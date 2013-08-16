module Plink
  class VirtualCurrency < ActiveRecord::Base
    self.table_name = "virtualCurrencies"
    self.primary_key = "virtualCurrencyID"

    include Plink::LegacyTimestamps

    DEFAULT_SUBDOMAIN = 'www'

    alias_attribute :name, :currencyName
    alias_attribute :exchange_rate, :exchangeRate
    alias_attribute :site_name, :siteName
    alias_attribute :singular_name, :singularCurrencyName
    alias_attribute :has_all_offers, :hasAllOffers
    alias_attribute :show_tiers_as_percent, :showTiersAsPercent

    attr_accessible :name, :subdomain, :exchange_rate, :site_name, :singular_name, :has_all_offers, :show_tiers_as_percent

    validates :name, :subdomain, :exchange_rate, :site_name, :singular_name, presence: true
    validates :subdomain, uniqueness: true

    def self.default
      self.find_by_subdomain(DEFAULT_SUBDOMAIN)
    end

    def self.find_by_sudomain(subdomain)
      where('subdomain = ?', subdomain)
    end

  end
end
