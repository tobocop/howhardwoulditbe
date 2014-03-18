module Plink
  class ReceiptPostbackRecord < ActiveRecord::Base
    self.table_name = 'receipt_postbacks'

    attr_accessible :processed, :event_id, :receipt_promotion_postback_url_id,
      :posted_url

    validates_presence_of :event_id, :receipt_promotion_postback_url_id
  end
end
