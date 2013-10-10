module Plink
  class RegistrationLinkSharePageRecord < ActiveRecord::Base
    self.table_name = 'registration_links_share_pages'

    belongs_to :registration_link_record, class_name:'Plink::RegistrationLinkRecord', foreign_key: 'registration_link_id'
    belongs_to :share_page_record, class_name:'Plink::SharePageRecord', foreign_key: 'share_page_id'

    attr_accessible :registration_link_id, :share_page_id
  end
end
