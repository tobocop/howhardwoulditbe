module Plink
  class AdvertiserRecord < ActiveRecord::Base
    self.table_name = 'advertisers'

    include Plink::LegacyTimestamps

    attr_accessible :advertiser_name, :logo_url

    def advertiser_name=(name)
      self.advertiserName = name
    end

    def advertiser_name
      self.advertiserName
    end

    def logo_url=(url)
      self.logoURL = url
    end

    def logo_url
      self.logoURL
    end
  end
end