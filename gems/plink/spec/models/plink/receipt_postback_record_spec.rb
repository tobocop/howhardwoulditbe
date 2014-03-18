require 'spec_helper'

describe Plink::ReceiptPostbackRecord do
  it { should allow_mass_assignment_of(:processed) }
  it { should allow_mass_assignment_of(:event_id) }
  it { should allow_mass_assignment_of(:receipt_promotion_postback_url_id) }
  it { should allow_mass_assignment_of(:posted_url) }

  let(:valid_params) {
    {
      processed: false,
      event_id: 3,
      receipt_promotion_postback_url_id: 3,
      posted_url: 'something'
    }
  }

  it 'can be persisted' do
    Plink::ReceiptPostbackRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:receipt_promotion_postback_url_id) }
  end
end
