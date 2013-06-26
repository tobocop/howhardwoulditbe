module Plink
  class AdvertiserRecord < ActiveRecord::Base
    self.table_name = 'advertisers'

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

    def created_at
      self.created
    end

    def updated_at
      self.modified
    end

    private

    def timestamp_attributes_for_create
      super << :created
    end

    def timestamp_attributes_for_update
      super << :modified
    end
  end
end