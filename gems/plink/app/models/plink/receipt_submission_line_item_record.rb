module Plink
  class ReceiptSubmissionLineItemRecord < ActiveRecord::Base
    self.table_name = 'receipt_submission_line_items'

    attr_accessible :dollar_amount, :description, :receipt_submission_id
  end
end
