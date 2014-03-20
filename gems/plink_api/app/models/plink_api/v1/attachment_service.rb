module PlinkApi
  module V1
    class AttachmentService
      attr_reader :attachments

      def initialize(attachments)
        @attachments = attachments
      end

      def upload_receipt_submission_attachments_to_s3(receipt_submission_record)
        bucket_name = 'plink-receipt-images'
        attachments.each_with_index do |attachment, index|
          file_name = "#{Rails.env}/#{receipt_submission_record.from_address}/#{receipt_submission_record.id}-#{index}-#{attachment.original_filename}"
          Plink::ReceiptSubmissionAttachmentRecord.create(
            receipt_submission_id: receipt_submission_record.id,
            url: "https://s3.amazonaws.com/#{bucket_name}/#{file_name}"
          )
          upload_to_s3(bucket_name, file_name, attachment.tempfile)
        end
      end

    private

      def upload_to_s3(bucket, object, file)
        AWS::S3.new.buckets[bucket].objects[object].write(file: file)
      end
    end
  end
end
