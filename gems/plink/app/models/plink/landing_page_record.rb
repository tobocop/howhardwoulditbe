module Plink
  class LandingPageRecord < ActiveRecord::Base

    self.table_name = 'landing_pages'

    has_many :registration_link_landing_page_records, class_name: 'Plink::RegistrationLinkLandingPageRecord', foreign_key: 'landing_page_id'
    has_many :registration_link_records, class_name: 'Plink::RegistrationLinkRecord', through: :registration_link_landing_page_records

    attr_accessible :name, :partial_path

    validates_presence_of :partial_path, :name

  end
end

