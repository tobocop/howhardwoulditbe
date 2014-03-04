module PlinkAdmin
  class ReceiptSubmissionQueueController < PlinkAdmin::ApplicationController
    def show
      receipt_submission_records = Plink::ReceiptSubmissionRecord.pending_by_queue(params[:id])
      @receipt_submissions_left = receipt_submission_records.length
      @receipt_submission_record = receipt_submission_records.first
      @receipt_promotions = Plink::ReceiptPromotionRecord.all
    end
  end
end
