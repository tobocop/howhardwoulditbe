require 'spec_helper'

describe Plink::ReceiptSubmissionRecord do
  it { should allow_mass_assignment_of(:approved) }
  it { should allow_mass_assignment_of(:body) }
  it { should allow_mass_assignment_of(:date_of_purchase) }
  it { should allow_mass_assignment_of(:dollar_amount) }
  it { should allow_mass_assignment_of(:from) }
  it { should allow_mass_assignment_of(:headers) }
  it { should allow_mass_assignment_of(:needs_additional_information) }
  it { should allow_mass_assignment_of(:queue) }
  it { should allow_mass_assignment_of(:receipt_promotion_id) }
  it { should allow_mass_assignment_of(:subject) }
  it { should allow_mass_assignment_of(:to) }
  it { should allow_mass_assignment_of(:user_id) }

  it { should have_many(:receipt_submission_attachment_records) }
  it { should belong_to(:receipt_promotion_record) }

  let(:valid_params) {
    {
      body: 'some body',
      date_of_purchase: Date.today,
      dollar_amount: 2.34,
      from: 'testing@example.com',
      headers: '{"some":"json"}',
      receipt_promotion_id: 1,
      subject: 'pepsi promotion',
      to: '{"some":"json"}',
      user_id: 23,
      queue: 1
    }
  }

  it 'can be persisted' do
    Plink::ReceiptSubmissionRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:from) }
  end

  describe 'named scopes' do
    describe '.pending_by_queue' do
      let!(:receipt_submission) { create_receipt_submission(queue: 1, approved: false, needs_additional_information: false) }
      subject(:pending_by_queue) { Plink::ReceiptSubmissionRecord.pending_by_queue(1) }

      it 'returns submissions that match the queue that have not been approved and do not need more information' do
        pending_by_queue.length.should == 1
        pending_by_queue.first.id.should == receipt_submission.id
      end

      it 'does not return records where the queue does not match' do
        receipt_submission.update_attribute('queue', 3)

        pending_by_queue.length.should == 0
      end

      it 'does not return approved records' do
        receipt_submission.update_attribute('approved', true)

        pending_by_queue.length.should == 0
      end

      it 'does not return records that need more information ' do
        receipt_submission.update_attribute('needs_additional_information', true)

        pending_by_queue.length.should == 0
      end
    end
  end

  describe '#valid_for_award?' do
    it 'returns true when the award is approved and has a receipt_promotion_id' do
      new_receipt_submission(approved: true, receipt_promotion_id: 3).valid_for_award?.should be_true
    end

    it 'returns false when the award is not approved' do
      new_receipt_submission(approved: false, receipt_promotion_id: 3).valid_for_award?.should be_false
    end

    it 'returns false when the award doest not have a receipt_promotion_id' do
      new_receipt_submission(approved: true, receipt_promotion_id: nil).valid_for_award?.should be_false
    end
  end

  describe '.award_type_id' do
    it 'returns the award_type_id from the associated promotion' do
      receipt_submission = new_receipt_submission(receipt_promotion_record: new_receipt_promotion(award_type_id: 4))
      receipt_submission.award_type_id.should == 4
    end
  end
end