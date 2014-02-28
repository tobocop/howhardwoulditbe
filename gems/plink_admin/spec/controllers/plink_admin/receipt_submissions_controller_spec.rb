require 'spec_helper'

describe PlinkAdmin::ReceiptSubmissionsController do
  let(:admin) { create_admin }
  let!(:receipt_submission) { create_receipt_submission }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end
  end

  describe 'PUT update' do
    let(:receipt_award_service) { double(Plink::ReceiptAwardService, award: true) }

    before do
      Plink::ReceiptAwardService.stub(:new).and_return(receipt_award_service)
    end

    it 'updates the record and redirects back to the queue' do
      Plink::ReceiptAwardService.should_receive(:new).with(receipt_submission).and_return(receipt_award_service)
      receipt_award_service.should_receive(:award).and_return(true)

      put :update, {queue: 1, id: receipt_submission.id, receipt_submission: {approved: true}}
      receipt_submission.reload.approved.should be_true
      flash[:notice].should == 'Submission updated and user awarded'
      response.should redirect_to '/receipt_submission_queue/1'
    end

    it 'redirects back to the queue when the record cannot be updated' do
      Plink::ReceiptSubmissionRecord.should_receive(:find).with(receipt_submission.id.to_s).and_return(receipt_submission)
      receipt_submission.stub(:update_attributes).and_return(false)

      put :update, {queue: 2, id: receipt_submission.id, receipt_submission: {}}

      flash[:notice].should == 'Submission could not be processed'
      response.should redirect_to '/receipt_submission_queue/2'
    end
  end
end
