require 'spec_helper'

describe Plink::ReceiptAwardService do
  let(:receipt_submission_record) { double(Plink::ReceiptSubmissionRecord, award_type_id: 4, user_id: 6) }

  subject(:receipt_award_service) { Plink::ReceiptAwardService.new(receipt_submission_record) }

  describe 'initialize' do
    it 'initializes with a receipt_submission_record' do
      award_service = Plink::ReceiptAwardService.new(receipt_submission_record)
      award_service.receipt_submission_record.should == receipt_submission_record
    end
  end

  describe '#award' do
    let(:free_award_service) { double(Plink::FreeAwardService, award: true) }

    before do
      receipt_submission_record.stub(:valid_for_award?).and_return(true)
      receipt_award_service.stub(:user_is_eligible?).and_return(true)
      Plink::FreeAwardService.stub(:new).and_return(free_award_service)
    end

    it 'validates that the receipt submission can be awarded' do
      receipt_submission_record.should_receive(:valid_for_award?).and_return(true)
      receipt_award_service.award
    end

    context 'when the receipt_submission_record can be awarded' do
      it 'awards the user' do
        Plink::FreeAwardService.should_receive(:new).with(1).and_return(free_award_service)
        free_award_service.should_receive(:award).with(6, 4)

        receipt_award_service.award
      end
    end

    context 'when the receipt_submission_record cannot be awarded' do
      before { receipt_submission_record.stub(:valid_for_award?).and_return(false) }

      it 'does not award the user' do
        Plink::FreeAwardService.should_not_receive(:new)

        receipt_award_service.award
      end
    end
  end

  describe '#user_is_eligible?' do
    it 'returns true if the user has not earned the free award type associaed to the submission' do
      Plink::FreeAwardRecord.should_receive(:awards_by_type_and_by_user_id).
        with(4, 6).
        and_return([])

      receipt_award_service.user_is_eligible?.should be_true
    end

    it 'returns false if the user has earned the free award type associaed to the submission' do
      Plink::FreeAwardRecord.should_receive(:awards_by_type_and_by_user_id).
        with(4, 6).
        and_return([double])

      receipt_award_service.user_is_eligible?.should be_false
    end
  end
end
