module Plink
  class AdvertiserRecord < ActiveRecord::Base
    self.table_name = 'advertisers'

    include Plink::LegacyTimestamps

    alias_attribute :advertiser_name, :advertiserName
    alias_attribute :logo_url, :logoURL

    attr_accessible :advertiser_name, :logo_url

  end
end