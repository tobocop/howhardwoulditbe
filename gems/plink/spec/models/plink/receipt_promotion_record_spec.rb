require 'spec_helper'

describe Plink::ReceiptPromotionRecord do
  it {should allow_mass_assignment_of(:advertiser_id) }
  it {should allow_mass_assignment_of(:award_type_id) }
  it {should allow_mass_assignment_of(:description) }
  it {should allow_mass_assignment_of(:end_date) }
  it {should allow_mass_assignment_of(:name) }
  it {should allow_mass_assignment_of(:start_date) }
  it { should allow_mass_assignment_of(:receipt_promotion_postback_urls_attributes) }

  it { should accept_nested_attributes_for(:receipt_promotion_postback_urls) }

  it { should have_many(:receipt_promotion_postback_urls) }
  it { should belong_to(:award_type_record) }
  it { should belong_to(:advertiser_record) }


  let(:valid_params) {
    {
      advertiser_id: 83,
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

  describe '#dollar_award_amount' do
    it 'returns the dollar_amount of the award_type record' do
      receipt_promotion = new_receipt_promotion(award_type_record: new_award_type(dollar_amount: 3.23))
      receipt_promotion.dollar_award_amount.should == 3.23
    end
  end
end
