module Plink
  class ReceiptSubmissionRecord < ActiveRecord::Base
    self.table_name = 'receipt_submissions'

    QUEUE_RANGE = 1..10

    belongs_to :receipt_promotion_record, class_name: 'Plink::ReceiptPromotionRecord', foreign_key: 'receipt_promotion_id'
    belongs_to :user_record, class_name: 'Plink::UserRecord', foreign_key: 'user_id'
    has_many :receipt_submission_attachment_records, class_name: 'Plink::ReceiptSubmissionAttachmentRecord', foreign_key: 'receipt_submission_id'
    has_many :receipt_submission_line_items, class_name: 'Plink::ReceiptSubmissionLineItemRecord', foreign_key: 'receipt_submission_id'

    accepts_nested_attributes_for :receipt_submission_line_items, reject_if: :all_blank

    attr_accessible :approved, :body, :date_of_purchase, :dollar_amount, :from_address, :headers,
      :needs_additional_information, :receipt_image_url, :receipt_promotion_id, :receipt_submission_line_items_attributes,
      :status, :status_reason, :store_number, :subject, :to_address, :time_of_purchase, :user_id,
      :queue

    validates_presence_of :from_address

    scope :pending_by_queue, ->(queue){
      where(queue: queue, status: 'pending')
    }

    scope :postback_data, -> {
      select('receipt_submissions.id, receipt_promotions_postback_urls.id as receipt_promotion_postback_url_id, events.eventID as event_id').
      joins('INNER JOIN receipt_promotions_postback_urls ON receipt_promotions_postback_urls.receipt_promotion_id = receipt_submissions.receipt_promotion_id').
      joins('INNER JOIN registration_links ON receipt_promotions_postback_urls.registration_link_id = registration_links.id').
      joins('INNER JOIN events ON receipt_submissions.user_id = events.userID').
      joins('INNER JOIN eventTypes ON events.eventTypeID = eventTypes.eventTypeID').
      where(status: 'approved').
      where('events.affiliateID = registration_links.affiliate_id').
      where('events.campaignID = registration_links.campaign_id').
      where('eventTypes.name = ?', Plink::EventTypeRecord.email_capture_type).
      where(%q{NOT EXISTS (
        SELECT 1
        FROM receipt_postbacks
        WHERE receipt_postbacks.event_id = events.eventID
          AND receipt_postbacks.receipt_promotion_postback_url_id = receipt_promotions_postback_urls.id
      )})

    }

    def self.map_postback_data
      postback_data.map do |record|
        {event_id: record.event_id, receipt_promotion_postback_url_id: record.receipt_promotion_postback_url_id}
      end
    end

    def valid_for_award?
      status == 'approved' && receipt_promotion_id.present?
    end

    def award_type_id
      receipt_promotion_record.award_type_id
    end

    def dollar_award_amount
      receipt_promotion_record.dollar_award_amount
    end
  end
end
