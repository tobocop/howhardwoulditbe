module Plink
  class RegistrationLinkRecord < ActiveRecord::Base
    self.table_name = 'registration_links'

    has_one :affiliate_record, class_name: 'Plink::AffiliateRecord', primary_key: 'affiliate_id', foreign_key: 'affiliateID'
    has_one :campaign_record, class_name: 'Plink::CampaignRecord', primary_key: 'campaign_id', foreign_key: 'campaignID'

    has_many :registration_link_landing_page_records, class_name: 'Plink::RegistrationLinkLandingPageRecord', foreign_key: 'registration_link_id'
    has_many :landing_page_records, class_name: 'Plink::LandingPageRecord', through: :registration_link_landing_page_records

    attr_accessible :affiliate_id, :campaign_id, :start_date, :end_date, :is_active, :landing_page_records

    validates_presence_of :affiliate_id, :campaign_id
  end
end
