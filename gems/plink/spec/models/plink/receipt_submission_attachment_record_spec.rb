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
end
