module Plink
  class ReceiptSubmissionAttachmentRecord < ActiveRecord::Base
    self.table_name = 'receipt_submission_attachments'

    attr_accessible :receipt_submission_id, :url
  end
end
