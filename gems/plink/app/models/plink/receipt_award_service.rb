module Plink
  class ReceiptAwardService
    attr_reader :receipt_submission_record

    def initialize(receipt_submission_record)
      @receipt_submission_record = receipt_submission_record
    end

    def award
      Plink::FreeAwardService.new(1).
        award(
          receipt_submission_record.user_id,
          receipt_submission_record.award_type_id
        ) if receipt_submission_record.valid_for_award? && user_is_eligible?
    end

    def user_is_eligible?
      !Plink::FreeAwardRecord.awards_by_type_and_by_user_id(receipt_submission_record.award_type_id, receipt_submission_record.user_id).present?
    end
  end
end
