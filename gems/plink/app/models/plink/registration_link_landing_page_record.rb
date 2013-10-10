module Plink
  class RegistrationLinkLandingPageRecord < ActiveRecord::Base
    self.table_name = 'registration_links_landing_pages'

    belongs_to :landing_page_record, class_name:'Plink::LandingPageRecord', foreign_key: 'landing_page_id'
    belongs_to :registration_link_record, class_name:'Plink::RegistrationLinkRecord', foreign_key: 'registration_link_id'

    attr_accessible :landing_page_id, :registration_link_id
  end
end
