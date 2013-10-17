module Plink
  class SharePageTrackingRecord < ActiveRecord::Base
    self.table_name = 'share_page_tracking'

    attr_accessible :registration_link_id, :shared, :share_page_id, :user_id

    validates_presence_of :registration_link_id, :user_id
  end
end
