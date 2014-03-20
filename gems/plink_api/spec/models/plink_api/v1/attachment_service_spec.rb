require 'spec_helper'

describe PlinkApi::V1::AttachmentService do
  let(:attachments) {
    [
      ActionDispatch::Http::UploadedFile.new(
        {
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path File.dirname(__FILE__)}/fixtures/img.png")
        }
      ),
      ActionDispatch::Http::UploadedFile.new(
        {
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path File.dirname(__FILE__)}/fixtures/img.png")
        }
      )
    ]
  }

  subject(:api_attachment_service) { PlinkApi::V1::AttachmentService }

  describe 'initialize' do
    it 'initializes with attachments' do
      attachment_service = api_attachment_service.new(attachments)
      attachment_service.attachments.should == attachments
    end
  end

  describe '#upload_receipt_submission_attachments_to_s3' do
    let(:receipt_submission_record) { double(Plink::ReceiptSubmissionRecord, id: 3, from_address: 'testing@example.com') }

    subject(:api_attachment_service) { PlinkApi::V1::AttachmentService.new(attachments) }

    before do
      api_attachment_service.stub(:upload_to_s3)
      Plink::ReceiptSubmissionAttachmentRecord.stub(:create)
    end

    it 'creates receipt submission photo records for each attachment' do
      Plink::ReceiptSubmissionAttachmentRecord.should_receive(:create).
        with({
          receipt_submission_id: 3,
          url: 'https://s3.amazonaws.com/plink-receipt-images/test/testing@example.com/3-0-img.png'
        }).
        and_return(true)

      Plink::ReceiptSubmissionAttachmentRecord.should_receive(:create).
        with({
          receipt_submission_id: 3,
          url: 'https://s3.amazonaws.com/plink-receipt-images/test/testing@example.com/3-1-img.png'
        }).
        and_return(true)

      api_attachment_service.upload_receipt_submission_attachments_to_s3(receipt_submission_record)
    end

    it 'uploads the attachments to s3' do
      api_attachment_service.should_receive(:upload_to_s3).with(
        'plink-receipt-images',
        'test/testing@example.com/3-0-img.png',
        attachments[0].tempfile
      )

      api_attachment_service.should_receive(:upload_to_s3).with(
        'plink-receipt-images',
        'test/testing@example.com/3-1-img.png',
        attachments[1].tempfile
      )

      api_attachment_service.upload_receipt_submission_attachments_to_s3(receipt_submission_record)
    end
  end
end
