require 'spec_helper'

describe Plink::ReceiptPromotionPostbackService do
  let(:receipt_postback_record) { double(Plink::ReceiptPostbackRecord, event_id: 3, receipt_promotion_postback_url_id: 4) }
  let(:event_record) {
    double(
      Plink::EventRecord,
      affiliate_id: 3,
      sub_id_two: 'something',
      user_id: 4
    )
  }
  let(:receipt_promotion_postback_url_record) {
    double(
      Plink::ReceiptPromotionPostbackUrlRecord,
      postback_url: 'http://example.com/$affiliate_id$/$sub_id_two$/$user_id$'
    )
  }

  subject(:receipt_promotion_postback_service) { Plink::ReceiptPromotionPostbackService.new(receipt_postback_record) }

  before do
    Plink::EventRecord.stub(:find).and_return(event_record)
    Plink::ReceiptPromotionPostbackUrlRecord.stub(:find).and_return(receipt_promotion_postback_url_record)
  end

  describe 'initialize' do
    it 'stores the receipt_postback' do
      receipt_promotion_postback_service.receipt_postback_record.should == receipt_postback_record
    end

    it 'looks up the correct event' do
      Plink::EventRecord.should_receive(:find).with(3).and_return(event_record)

      receipt_promotion_postback_service.event_record.should == event_record
    end

    it 'looks up the correct receipt_promotion_postback_url' do
      Plink::ReceiptPromotionPostbackUrlRecord.should_receive(:find).with(4).and_return(receipt_promotion_postback_url_record)

      receipt_promotion_postback_service.receipt_promotion_postback_url_record.should == receipt_promotion_postback_url_record
    end
  end

  describe '#process!' do
    before do
      receipt_promotion_postback_service.stub(:perform_get)
      receipt_postback_record.stub(:update_attributes)
    end

    it 'calls perform_get' do
      receipt_promotion_postback_service.should_receive(:perform_get)

      receipt_promotion_postback_service.process!
    end

    it 'updates the postback record marking it as processed' do
      receipt_postback_record.should_receive(:update_attributes).with(
        processed: true,
        posted_url: 'http://example.com/3/something/4'
      )

      receipt_promotion_postback_service.process!
    end
  end
end
