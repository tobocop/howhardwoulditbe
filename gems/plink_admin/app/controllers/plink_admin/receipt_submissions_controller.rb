module PlinkAdmin
  class ReceiptSubmissionsController < PlinkAdmin::ApplicationController
    def index

    end

    def update
      receipt_submission = Plink::ReceiptSubmissionRecord.find(params[:id])

      if receipt_submission.update_attributes(params[:receipt_submission])
        if Plink::ReceiptAwardService.new(receipt_submission).award
          flash[:notice] = 'Submission updated and user awarded'
        else
          flash[:notice] = 'Submission updated'
        end
      else
        flash[:notice] = 'Submission could not be processed'
      end

      redirect_to plink_admin.receipt_submission_queue_path(params[:queue])
    end
  end
end
