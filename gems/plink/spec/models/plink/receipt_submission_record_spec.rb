require 'spec_helper'

describe Plink::ReceiptSubmissionRecord do
  it { should allow_mass_assignment_of(:approved) }
  it { should allow_mass_assignment_of(:body) }
  it { should allow_mass_assignment_of(:date_of_purchase) }
  it { should allow_mass_assignment_of(:dollar_amount) }
  it { should allow_mass_assignment_of(:from_address) }
  it { should allow_mass_assignment_of(:headers) }
  it { should allow_mass_assignment_of(:needs_additional_information) }
  it { should allow_mass_assignment_of(:queue) }
  it { should allow_mass_assignment_of(:receipt_promotion_id) }
  it { should allow_mass_assignment_of(:status) }
  it { should allow_mass_assignment_of(:status_reason) }
  it { should allow_mass_assignment_of(:subject) }
  it { should allow_mass_assignment_of(:to_address) }
  it { should allow_mass_assignment_of(:user_id) }

  it { should have_many(:receipt_submission_attachment_records) }
  it { should belong_to(:receipt_promotion_record) }

  let(:valid_params) {
    {
      body: 'some body',
      date_of_purchase: Date.today,
      dollar_amount: 2.34,
      from_address: 'testing@example.com',
      headers: '{"some":"json"}',
      queue: 1,
      receipt_promotion_id: 1,
      status: 'pending',
      status_reason:  nil,
      subject: 'pepsi promotion',
      to_address: 'something@test.com',
      user_id: 23
    }
  }

  it 'can be persisted' do
    Plink::ReceiptSubmissionRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:from_address) }
  end

  describe 'named scopes' do
    describe '.pending_by_queue' do
      let!(:receipt_submission) { create_receipt_submission(queue: 1, status: 'pending') }
      subject(:pending_by_queue) { Plink::ReceiptSubmissionRecord.pending_by_queue(1) }

      it 'returns submissions that match the queue that are pending' do
        pending_by_queue.length.should == 1
        pending_by_queue.first.id.should == receipt_submission.id
      end

      it 'does not return records where the queue does not match' do
        receipt_submission.update_attribute('queue', 3)

        pending_by_queue.length.should == 0
      end

      it 'does not return records where the status is not pending' do
        receipt_submission.update_attribute('status', 'derp')

        pending_by_queue.length.should == 0
      end
    end

    describe '.postback_data' do
      let!(:event_type) { create_event_type(name: Plink::EventTypeRecord.email_capture_type) }
      let!(:event_one) { create_event(user_id: 4, affiliate_id: 8, campaign_id: 5, event_type_id: event_type.id) }
      let!(:event_two) { create_event(user_id: 4, affiliate_id: 9, campaign_id: 5, event_type_id: event_type.id) }
      let!(:event_three) { create_event(user_id: 4, affiliate_id: 8, campaign_id: 2, event_type_id: event_type.id) }
      let!(:event_four) { create_event(user_id: 7, affiliate_id: 8, campaign_id: 5, event_type_id: event_type.id) }
      let!(:event_five) { create_event(user_id: 7, affiliate_id: 8, campaign_id: 5, event_type_id: event_type.id) }
      let!(:registration_link) { create_registration_link(affiliate_id: 8, campaign_id: 5, landing_page_records: [new_landing_page]) }
      let!(:receipt_promotion_postback_url) { create_receipt_promotion_postback_url(receipt_promotion_id: 3, registration_link_id: registration_link.id) }
      let!(:first_receipt_submission) { create_receipt_submission(receipt_promotion_id: 3, user_id: 4, approved: true) }
      let!(:second_receipt_submission) { create_receipt_submission(receipt_promotion_id: 3, user_id: 7, approved: true) }

      subject(:postback_data) { Plink::ReceiptSubmissionRecord.postback_data }

      before do
        create_receipt_postback(receipt_promotion_postback_url_id: receipt_promotion_postback_url.id, event_id: event_five.id)
      end

      it 'returns returns the submission records valid for postback' do
        postback_data.should == [first_receipt_submission, second_receipt_submission]
      end
    end
  end

  describe '.map_postback_data' do
    before do
      Plink::ReceiptSubmissionRecord.stub(:postback_data).and_return([
        double(event_id: 3, receipt_promotion_postback_url_id: 4),
        double(event_id: 8, receipt_promotion_postback_url_id: 1)
      ])
    end

    it 'maps the return of postback data to event_id and receipt_promotion_postback_url_id' do
      Plink::ReceiptSubmissionRecord.map_postback_data.should == [
        {event_id: 3, receipt_promotion_postback_url_id: 4},
        {event_id: 8, receipt_promotion_postback_url_id: 1}
      ]
    end
  end

  describe '#valid_for_award?' do
    it 'returns true when the status is approved and has a receipt_promotion_id' do
      new_receipt_submission(status: 'approved', receipt_promotion_id: 3).valid_for_award?.should be_true
    end

    it 'returns false when the submission is not approved' do
      new_receipt_submission(status: 'denied', receipt_promotion_id: 3).valid_for_award?.should be_false
    end

    it 'returns false when the submission does not have a receipt_promotion_id' do
      new_receipt_submission(status: 'approved', receipt_promotion_id: nil).valid_for_award?.should be_false
    end
  end

  describe '#award_type_id' do
    it 'returns the award_type_id from the associated promotion' do
      receipt_submission = new_receipt_submission(receipt_promotion_record: new_receipt_promotion(award_type_id: 4))
      receipt_submission.award_type_id.should == 4
    end
  end

  describe '#dollar_award_amount' do
    it 'returns the dollar_award_amount from the associated promotion' do
      receipt_promotion = new_receipt_promotion
      receipt_promotion.stub(:dollar_award_amount).and_return(5)
      receipt_submission = new_receipt_submission(receipt_promotion_record: receipt_promotion)
      receipt_submission.dollar_award_amount.should == 5
    end
  end
end
