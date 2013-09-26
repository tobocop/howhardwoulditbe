module Plink
  class EventRecord < ActiveRecord::Base

    self.table_name = 'events'

    include Plink::LegacyTimestamps

    alias_attribute :event_type_id, :eventTypeID
    alias_attribute :user_id, :userID
    alias_attribute :affiliate_id, :affiliateID
    alias_attribute :campaign_id, :campaignID
    alias_attribute :sub_id, :subID
    alias_attribute :sub_id_two, :subID2
    alias_attribute :sub_id_three, :subID3
    alias_attribute :sub_id_four, :subID4
    alias_attribute :path_id, :pathID
    alias_attribute :is_active, :isActive

    attr_accessible :event_type_id,
                    :user_id,
                    :affiliate_id,
                    :campaign_id,
                    :sub_id,
                    :sub_id_two,
                    :sub_id_three,
                    :sub_id_four,
                    :path_id,
                    :landing_page_id,
                    :ip,
                    :is_active

  end
end
