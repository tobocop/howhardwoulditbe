module Plink
  class ReceiptPromotionRecord < ActiveRecord::Base
    self.table_name = 'receipt_promotions'

    attr_accessible :award_type_id, :description, :end_date, :name, :start_date

    validates_presence_of :award_type_id, :name
  end
end
