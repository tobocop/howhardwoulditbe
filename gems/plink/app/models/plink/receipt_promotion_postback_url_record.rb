module Plink
  class ReceiptPromotionPostbackUrlRecord < ActiveRecord::Base
    self.table_name = 'receipt_promotions_postback_urls'

    attr_accessible :postback_url, :receipt_promotion_id, :registration_link_id

    validates_presence_of :postback_url, :registration_link_id
  end
end
