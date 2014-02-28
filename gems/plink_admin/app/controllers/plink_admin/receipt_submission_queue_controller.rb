module PlinkAdmin
  class ReceiptSubmissionQueueController < PlinkAdmin::ApplicationController
    def show
      @receipt_submission_record = Plink::ReceiptSubmissionRecord.pending_by_queue(params[:id]).first
      @receipt_promotions = Plink::ReceiptPromotionRecord.all
    end
  end
end
