module Plink
  class RegistrationLinkLandingPageRecord < ActiveRecord::Base
    self.table_name = 'registration_links_landing_pages'
    
    belongs_to :registration_link_record, class_name:'Plink::RegistrationLinkRecord', foreign_key: 'registration_link_id'
    belongs_to :landing_page_record, class_name:'Plink::LandingPageRecord', foreign_key: 'landing_page_id'

    attr_accessible :registration_link_id, :landing_page_id
  end
end
