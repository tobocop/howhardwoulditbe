module Plink
  class ReceiptSubmissionRecord < ActiveRecord::Base
    self.table_name = 'receipt_submissions'

    attr_accessible :body, :from, :headers, :receipt_image_url, :subject, :to, :user_id

    validates_presence_of :from
  end
end
