require 'spec_helper'

describe Plink::RegistrationLinkRecord do
  let(:valid_params) {
    {
      affiliate_id: 123,
      campaign_id: 123,
      start_date: 1.day.ago,
      end_date: 1.day.from_now,
      is_active: true
    }
  }

  it { should have_one(:affiliate_record) }
  it { should have_one(:campaign_record) }

  it { should have_many(:registration_link_landing_page_records) }
  it { should have_many(:landing_page_records).through(:registration_link_landing_page_records) }

  it 'can be persisted' do
    Plink::RegistrationLinkRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it 'is invalid without an affiliate_id' do
      registration_link_record = Plink::RegistrationLinkRecord.new
      registration_link_record.should_not be_valid
      registration_link_record.should have(1).error_on(:affiliate_id)
    end

    it 'is invalid without a campaign_id' do
      registration_link_record = Plink::RegistrationLinkRecord.new
      registration_link_record.should_not be_valid
      registration_link_record.should have(1).error_on(:campaign_id)
    end
  end
end
