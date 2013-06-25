module Plink
  class Offer < ActiveRecord::Base

    self.table_name = 'offers'

    attr_accessible :advertiser_name, :advertiser_id, :advertisers_rev_share, :detail_text, :start_date

    def advertiser_name=(name)
      self.advertiserName = name
    end

    def advertiser_name
      self.advertiserName
    end

    def advertiser_id=(id)
      self.advertiserID = id
    end

    def advertisers_rev_share=(amount)
      self.advertisersRevShare = amount
    end

    def detail_text=(text)
      self.detailText = text
    end

    def start_date=(date)
      self.startDate = date
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