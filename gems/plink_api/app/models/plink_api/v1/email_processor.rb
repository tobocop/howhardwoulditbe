module PlinkApi
  module V1
    class EmailProcessor
      def self.process(email)
        create_params = {
          body: email.body,
          from_address: email.from,
          headers: email.headers.to_json,
          queue: Random.rand(Plink::ReceiptSubmissionRecord::QUEUE_RANGE),
          subject: email.subject,
          status: 'pending',
          to_address: email.to.to_json
        }
        user = Plink::UserService.new.find_by_email(email.from)
        create_params.merge!(user_id: user.id) if user
        receipt_submission = Plink::ReceiptSubmissionRecord.create(create_params)
        PlinkApi::V1::AttachmentService.new(email.attachments).upload_receipt_submission_attachments_to_s3(receipt_submission) if email.attachments.present?
      end
    end
  end
end
