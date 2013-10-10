module Plink
  class RegistrationLinkRecord < ActiveRecord::Base
    self.table_name = 'registration_links'

    has_one :affiliate_record, class_name: 'Plink::AffiliateRecord', primary_key: 'affiliate_id', foreign_key: 'affiliateID'
    has_one :campaign_record, class_name: 'Plink::CampaignRecord', primary_key: 'campaign_id', foreign_key: 'campaignID'

    has_many :registration_link_landing_page_records, class_name: 'Plink::RegistrationLinkLandingPageRecord', foreign_key: 'registration_link_id'
    has_many :landing_page_records, class_name: 'Plink::LandingPageRecord', through: :registration_link_landing_page_records

    has_many :registration_link_share_page_records, class_name: 'Plink::RegistrationLinkSharePageRecord',foreign_key: 'registration_link_id'
    has_many :share_page_records, class_name: 'Plink::SharePageRecord', through: :registration_link_share_page_records

    attr_accessible :affiliate_id, :campaign_id, :end_date, :is_active,
      :landing_page_records, :share_flow, :share_page_records, :start_date

    attr_accessor :share_flow

    validates_presence_of :affiliate_id, :campaign_id

    validates_presence_of :landing_page_records
    validates_presence_of :share_page_records, if: lambda { share_flow == 'true' }

    def live?
      Date.current >= start_date.to_date && Date.current <= end_date.to_date
    end
  end
end
