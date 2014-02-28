require 'spec_helper'

describe Plink::ReceiptSubmissionAttachmentRecord do
  it { should allow_mass_assignment_of(:receipt_submission_id) }
  it { should allow_mass_assignment_of(:url) }

  let(:valid_params) {
    {
      receipt_submission_id: 3,
      url: 'anything'
    }
  }

  it 'can be persised' do
    Plink::ReceiptSubmissionAttachmentRecord.create(valid_params).should be_persisted
  end

  describe '.image?' do
    it 'returns true if the extension is jpeg, , , or ' do
      new_receipt_submission_attachment(url: 'something.jpeg').image?.should be_true
    end

    it 'returns ture if the extension is jpg' do
      new_receipt_submission_attachment(url: 'something.jpg').image?.should be_true
    end

    it 'returns ture if the extension is png' do
      new_receipt_submission_attachment(url: 'something.png').image?.should be_true
    end

    it 'returns ture if the extension is gif' do
      new_receipt_submission_attachment(url: 'something.gif').image?.should be_true
    end

    it 'returns false if the extension is not jpeg, jpg, png, or gif' do
      new_receipt_submission_attachment(url: 'something.pdf').image?.should be_false
    end
  end
end
