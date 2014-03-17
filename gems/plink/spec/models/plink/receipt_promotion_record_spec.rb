require 'spec_helper'

describe Plink::ReceiptPromotionRecord do
  it {should allow_mass_assignment_of(:award_type_id) }
  it {should allow_mass_assignment_of(:description) }
  it {should allow_mass_assignment_of(:end_date) }
  it {should allow_mass_assignment_of(:name) }
  it {should allow_mass_assignment_of(:start_date) }
  it { should allow_mass_assignment_of(:receipt_promotion_postback_urls_attributes) }

  it { should accept_nested_attributes_for(:receipt_promotion_postback_urls) }

  it { should have_many(:receipt_promotion_postback_urls) }


  let(:valid_params) {
    {
      award_type_id: 2,
      description: 'desc',
      end_date: 2.days.from_now,
      name: 'asd',
      start_date: 1.day.ago
    }
  }

  it 'can be persisted' do
    Plink::ReceiptPromotionRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:award_type_id) }
    it { should validate_presence_of(:name) }
  end
end
