module Plink
  class CampaignRecord < ActiveRecord::Base

    self.table_name = 'campaigns'

    include Plink::LegacyTimestamps

    alias_attribute :campaign_hash, :urlCParam

    attr_accessible :campaign_hash

    def self.for_campaign_hash(campaign_hash)
      where('urlCParam = ?', campaign_hash).first
    end
  end
end