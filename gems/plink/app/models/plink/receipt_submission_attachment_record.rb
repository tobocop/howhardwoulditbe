module Plink
  class ReceiptSubmissionAttachmentRecord < ActiveRecord::Base
    self.table_name = 'receipt_submission_attachments'

    attr_accessible :receipt_submission_id, :url

    def image?
      ['jpg', 'jpeg', 'gif', 'png'].include?(url.split('.').last.downcase)
    end
  end
end
