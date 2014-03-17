require 'spec_helper'

describe Plink::ReceiptPromotionPostbackUrlRecord do
  it { should allow_mass_assignment_of(:postback_url) }
  it { should allow_mass_assignment_of(:receipt_promotion_id) }
  it { should allow_mass_assignment_of(:registration_link_id) }

  let(:valid_params) {
    {
      postback_url: 'ewofih',
      receipt_promotion_id: 2,
      registration_link_id: 3
    }
  }

  it 'can be persisted' do
    Plink::ReceiptPromotionPostbackUrlRecord.create(valid_params).should be_persisted
  end

  it { should validate_presence_of(:postback_url) }
  it { should validate_presence_of(:registration_link_id) }
end
