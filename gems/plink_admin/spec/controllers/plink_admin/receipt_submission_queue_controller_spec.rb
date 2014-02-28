require 'spec_helper'

describe PlinkAdmin::ReceiptSubmissionQueueController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET show' do
    let(:receipt_submission_record) { double(Plink::ReceiptSubmissionRecord) }
    let(:receipt_submission_records) { [receipt_submission_record] }
    let(:receipt_promotion_record) { double(Plink::ReceiptPromotionRecord) }

    before do
      Plink::ReceiptSubmissionRecord.stub(:pending_by_queue).and_return(receipt_submission_records)
      Plink::ReceiptPromotionRecord.stub(:all).and_return([receipt_promotion_record])
    end

    it 'responds with a 200' do
      get :show, {id: 1}

      response.status.should == 200
    end

    it 'looks up the first pending submission by queue id' do
      Plink::ReceiptSubmissionRecord.should_receive(:pending_by_queue).with('1').and_return(receipt_submission_records)
      receipt_submission_records.should_receive(:first).and_return(receipt_submission_record)

      get :show, {id: 1}
    end

    it 'assigns a receipt_submission_record' do
      get :show, {id: 1}

      assigns(:receipt_submission_record).should == receipt_submission_record
    end

    it 'assigns all the receipt promotions' do
      get :show, {id: 1}

      assigns(:receipt_promotions).should == [receipt_promotion_record]
    end
  end
end

