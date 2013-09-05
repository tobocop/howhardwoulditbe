module Plink
  class AdvertiserRecord < ActiveRecord::Base
    self.table_name = 'advertisers'

    include Plink::LegacyTimestamps

    alias_attribute :advertiser_name, :advertiserName
    alias_attribute :logo_url, :logoURL
    alias_attribute :map_search_term, :mapSearchTerm

    attr_accessible :advertiser_name, :logo_url, :map_search_term

  end
end
