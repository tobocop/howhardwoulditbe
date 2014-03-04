module Plink
  class ReceiptSubmissionRecord < ActiveRecord::Base
    self.table_name = 'receipt_submissions'

    QUEUE_RANGE = 1..10

    attr_accessible :approved, :body, :date_of_purchase, :dollar_amount, :from, :headers,
      :needs_additional_information, :receipt_image_url, :receipt_promotion_id, :subject,
      :to, :user_id, :queue

    validates_presence_of :from

    belongs_to :receipt_promotion_record, class_name: 'Plink::ReceiptPromotionRecord', foreign_key: 'receipt_promotion_id'
    has_many :receipt_submission_attachment_records, class_name: 'Plink::ReceiptSubmissionAttachmentRecord', foreign_key: 'receipt_submission_id'

    scope :pending_by_queue, ->(queue){
      where(queue: queue, approved: false, needs_additional_information: false)
    }

    def valid_for_award?
      approved && receipt_promotion_id.present?
    end

    def award_type_id
      receipt_promotion_record.award_type_id
    end
  end
end
