require 'spec_helper'

describe PlinkAdmin::ReceiptSubmissionQueueController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET show' do
    let(:receipt_submission_record) { double(Plink::ReceiptSubmissionRecord, user_id: 38) }
    let(:receipt_submission_records) { [receipt_submission_record] }
    let(:receipt_promotion_record) { double(Plink::ReceiptPromotionRecord) }
    let(:join_event) { double(Plink::EventRecord) }

    before do
      Plink::ReceiptSubmissionRecord.stub(:pending_by_queue).and_return(receipt_submission_records)
      Plink::ReceiptPromotionRecord.stub(:all).and_return([receipt_promotion_record])
      Plink::EventService.stub(:get_email_capture_event).and_return(join_event)
    end

    it 'responds with a 200' do
      get :show, {id: 1}

      response.status.should == 200
    end

    it 'looks up the pendings submissions by queue' do
      Plink::ReceiptSubmissionRecord.should_receive(:pending_by_queue).with('1').and_return(receipt_submission_records)

      get :show, {id: 1}
    end

    it 'assigns a count of submissions left to process' do
      get :show, {id: 1}

      assigns(:receipt_submissions_left).should == 1
    end

    it 'assigns a receipt_submission_record' do
      receipt_submission_records.should_receive(:first).and_return(receipt_submission_record)

      get :show, {id: 1}

      assigns(:receipt_submission_record).should == receipt_submission_record
    end

    it 'assigns the users join event' do
      Plink::EventService.should_receive(:get_email_capture_event).with(38).and_return(join_event)

      get :show, {id: 1}

      assigns(:users_join_event).should == join_event
    end

    it 'assigns all the receipt promotions' do
      get :show, {id: 1}

      assigns(:receipt_promotions).should == [receipt_promotion_record]
    end
  end
end

