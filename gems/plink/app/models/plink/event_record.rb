module Plink
  class EventRecord < ActiveRecord::Base

    self.table_name = 'events'

    include Plink::LegacyTimestamps

    belongs_to :affiliate_record, class_name: 'Plink::AffiliateRecord', foreign_key: 'affiliateID'

    alias_attribute :affiliate_id, :affiliateID
    alias_attribute :campaign_id, :campaignID
    alias_attribute :event_type_id, :eventTypeID
    alias_attribute :is_active, :isActive
    alias_attribute :path_id, :pathID
    alias_attribute :sub_id, :subID
    alias_attribute :sub_id_two, :subID2
    alias_attribute :sub_id_three, :subID3
    alias_attribute :sub_id_four, :subID4
    alias_attribute :user_id, :userID

    attr_accessible :affiliate_id, :campaign_id, :event_type_id, :ip, :is_active,
      :landing_page_id, :path_id, :sub_id, :sub_id_two, :sub_id_three, :sub_id_four,
      :user_id
  end
end
