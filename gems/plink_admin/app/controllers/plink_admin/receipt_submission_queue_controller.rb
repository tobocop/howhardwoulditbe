module PlinkAdmin
  class ReceiptSubmissionQueueController < PlinkAdmin::ApplicationController
    def show
      receipt_submission_records = Plink::ReceiptSubmissionRecord.pending_by_queue(params[:id])
      @receipt_submissions_left = receipt_submission_records.length
      @receipt_submission_record = receipt_submission_records.first
      @receipt_promotions = Plink::ReceiptPromotionRecord.all
      if @receipt_submission_record
        @receipt_submission_record.receipt_submission_line_items.build
        @users_join_event = Plink::EventService.get_email_capture_event(@receipt_submission_record.user_id)
      end
    end
  end
end
