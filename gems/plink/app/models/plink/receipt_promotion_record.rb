module Plink
  class ReceiptPromotionRecord < ActiveRecord::Base
    self.table_name = 'receipt_promotions'

    has_many :receipt_promotion_postback_urls, class_name: 'Plink::ReceiptPromotionPostbackUrlRecord', foreign_key: 'receipt_promotion_id'

    attr_accessible :award_type_id, :description, :end_date, :name,
      :receipt_promotion_postback_urls_attributes, :start_date

    accepts_nested_attributes_for :receipt_promotion_postback_urls, allow_destroy: true, reject_if: lambda { |attributes| attributes[:postback_url].blank? }

    validates_presence_of :award_type_id, :name
  end
end
