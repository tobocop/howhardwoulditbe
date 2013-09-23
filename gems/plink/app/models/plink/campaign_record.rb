module Plink
  class CampaignRecord < ActiveRecord::Base

    self.table_name = 'campaigns'

    include Plink::LegacyTimestamps

    alias_attribute :campaign_hash, :urlCParam
    alias_attribute :media_type, :mediaType
    alias_attribute :is_incent, :isIncent

    attr_accessible :campaign_hash, :name, :media_type, :creative, :is_incent, :start_date, :end_date

    validates_presence_of :name

    def self.for_campaign_hash(campaign_hash)
      where('urlCParam = ?', campaign_hash).first
    end
  end
end
