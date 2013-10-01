module Plink
  class RegistrationLinkMappingRecord < ActiveRecord::Base
    self.table_name = 'registration_link_mappings'

    belongs_to :registration_link_record, class_name: 'Plink::RegistrationLinkRecord', foreign_key: :registration_link_id

    attr_accessible :affiliate_id, :campaign_id, :registration_link_id
  end
end
