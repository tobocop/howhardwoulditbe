require 'spec_helper'

describe 'receipt_promotions:process_postback' do
  include_context 'rake'

  let!(:event_type) { create_event_type(name: Plink::EventTypeRecord.email_capture_type) }
  let!(:event_one) { create_event(user_id: 4, affiliate_id: 8, campaign_id: 5, event_type_id: event_type.id) }
  let!(:registration_link) { create_registration_link(affiliate_id: 8, campaign_id: 5, landing_page_records: [new_landing_page]) }
  let!(:receipt_promotion_postback_url) {
    create_receipt_promotion_postback_url(
      postback_url: 'http://example.com',
      receipt_promotion_id: 3,
      registration_link_id: registration_link.id
    )
  }
  let!(:first_receipt_submission) { create_receipt_submission(receipt_promotion_id: 3, user_id: 4, approved: true) }

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'gets postback data' do
      Plink::ReceiptSubmissionRecord.should_receive(:map_postback_data).and_return([])

      subject.invoke
    end

    it 'creates postback records for new submissions', :vcr do
      subject.invoke

      postback_records = Plink::ReceiptPostbackRecord.all
      postback_records.length.should == 1
      postback_records.first.event_id.should == event_one.id
      postback_records.first.receipt_promotion_postback_url_id.should == receipt_promotion_postback_url.id
    end

    it 'processes the postback records', :vcr do
      subject.invoke

      postback_records = Plink::ReceiptPostbackRecord.all
      postback_records.length.should == 1
      postback_records.first.processed.should be_true
    end
  end


  context 'when there are exceptions' do
    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::ReceiptSubmissionRecord.stub(:map_postback_data).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /receipt_promotions:process_postback/
      end

      subject.invoke
    end

    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      Plink::ReceiptPromotionPostbackService.stub(:new).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /receipt_promotions:process_postback failed on postback/
      end

      subject.invoke
    end
  end
end
