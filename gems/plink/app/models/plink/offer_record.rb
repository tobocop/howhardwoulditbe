module Plink
  class OfferRecord < ActiveRecord::Base

    self.table_name = 'offers'

    attr_accessible :advertiser_name, :advertiser_id, :advertisers_rev_share, :detail_text, :start_date

    has_many :offers_virtual_currencies, class_name: 'Plink::OffersVirtualCurrencyRecord', foreign_key: 'offerID'
    has_many :tiers, through: :offers_virtual_currencies
    belongs_to :advertiser, class_name: 'Plink::AdvertiserRecord', foreign_key: 'advertiserID'

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

    def detail_text
      self.detailText
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