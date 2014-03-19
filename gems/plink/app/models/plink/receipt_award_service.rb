module Plink
  class ReceiptAwardService
    attr_reader :receipt_submission_record

    def initialize(receipt_submission_record)
      @receipt_submission_record = receipt_submission_record
    end

    def award
      Plink::FreeAwardService.new(receipt_submission_record.dollar_award_amount).
        award_unique(
          receipt_submission_record.user_id,
          receipt_submission_record.award_type_id
        ) if receipt_submission_record.valid_for_award?
    end
  end
end
