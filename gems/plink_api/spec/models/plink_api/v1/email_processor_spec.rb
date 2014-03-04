require 'spec_helper'

describe PlinkApi::V1::EmailProcessor do
  describe '.process' do
    let(:email_to) {
      [
        {
          token: 'pepsipromo',
          host: 'plinkreceipts.com',
          email: 'pepsipromo@plinkreceipts.com',
          full: 'Some User <pepsipromo@plinkreceipts.com>',
          name: 'Some User'
        }
      ]
    }
    let(:attachments) {[double(ActionDispatch::Http::UploadedFile), double(ActionDispatch::Http::UploadedFile)]}
    let(:headers) { {header_one: 'asd', header_two: 'asd'} }
    let(:email) {
      double(
        Griddler::Email,
        body: 'some body',
        from: 'testing@example.com',
        headers: headers,
        subject: 'pepsi promotion',
        to: email_to,
        attachments: attachments
      )
    }
    let(:submission_create_params) {
      {
        body: 'some body',
        from: 'testing@example.com',
        headers: headers.to_json,
        queue: 2,
        subject: 'pepsi promotion',
        to: email_to.to_json
      }
    }
    let(:user) { double(Plink::User, id: 23) }
    let(:receipt_submission_record) { double(Plink::ReceiptSubmissionRecord) }
    let(:plink_user_service) { double(Plink::UserService, find_by_email: user) }
    let(:attachment_service) { double(PlinkApi::V1::AttachmentService, upload_receipt_submission_attachments_to_s3: true) }

    before do
      Plink::UserService.stub(:new).and_return(plink_user_service)
      Plink::ReceiptSubmissionRecord.stub(:create).and_return(receipt_submission_record)
      PlinkApi::V1::AttachmentService.stub(:new).and_return(attachment_service)
      Random.stub(:rand).and_return(2)
    end

    it 'assigns a random queue' do
      Random.should_receive(:rand).with(Plink::ReceiptSubmissionRecord::QUEUE_RANGE).and_return(2)

      PlinkApi::V1::EmailProcessor.process(email)
    end

    it 'looks up the user by email address' do
      plink_user_service.should_receive(:find_by_email).with('testing@example.com').and_return(user)

      PlinkApi::V1::EmailProcessor.process(email)
    end

    context 'when it finds a user' do
      it 'creates a receipt submission with a user_id' do
        Plink::ReceiptSubmissionRecord.should_receive(:create).
          with(submission_create_params.merge(user_id: 23)).
          and_return(receipt_submission_record)

        PlinkApi::V1::EmailProcessor.process(email)
      end
    end

    context 'when it does not find a user' do
      let(:user) { nil }

      it 'does creates a receipt submission without a user_id' do
        Plink::ReceiptSubmissionRecord.should_receive(:create).
          with(submission_create_params).
          and_return(receipt_submission_record)

        PlinkApi::V1::EmailProcessor.process(email)
      end
    end

    context 'when there are attachments' do
      it 'uploads the attachments to s3' do
        PlinkApi::V1::AttachmentService.should_receive(:new).
          with(attachments).
          and_return(attachment_service)
        attachment_service.should_receive(:upload_receipt_submission_attachments_to_s3).
          with(receipt_submission_record)

        PlinkApi::V1::EmailProcessor.process(email)
      end
    end

    context 'when there are no attachments' do
      before { email.stub(:attachments).and_return([]) }

      it 'does not upload attachments' do
        PlinkApi::V1::AttachmentService.should_not_receive(:new)

        PlinkApi::V1::EmailProcessor.process(email)
      end
    end
  end
end
