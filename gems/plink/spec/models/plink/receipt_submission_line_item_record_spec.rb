require 'spec_helper'

describe Plink::ReceiptSubmissionLineItemRecord do
  it{ should allow_mass_assignment_of(:dollar_amount) }
  it{ should allow_mass_assignment_of(:description) }
  it{ should allow_mass_assignment_of(:receipt_submission_id) }

  let(:valid_params) {
    {
      dollar_amount: 1.23,
      description: 'derps',
      receipt_submission_id: 2
    }
  }

  it 'can be persisted' do
    Plink::ReceiptSubmissionLineItemRecord.create(valid_params).should be_persisted
  end
end
