require 'spec_helper'

describe Plink::RegistrationLinkRecord do
  let(:landing_page_record) { create_landing_page }
  let(:valid_params) {
    {
      affiliate_id: 123,
      campaign_id: 123,
      end_date: 1.day.from_now,
      is_active: true,
      landing_page_records: [landing_page_record],
      mobile_detection_on: true,
      start_date: 1.day.ago,
    }
  }

  it { should allow_mass_assignment_of(:affiliate_id) }
  it { should allow_mass_assignment_of(:campaign_id) }
  it { should allow_mass_assignment_of(:start_date) }
  it { should allow_mass_assignment_of(:end_date) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:landing_page_records) }
  it { should allow_mass_assignment_of(:mobile_detection_on) }
  it { should allow_mass_assignment_of(:share_flow) }
  it { should allow_mass_assignment_of(:share_page_records) }

  it { should validate_presence_of(:landing_page_records) }
  it 'validates the presence of share_pages_records if it is a share_flow' do
    record = Plink::RegistrationLinkRecord.new(valid_params)
    record.share_flow = 'true'
    record.valid?.should be_false
    record.should have(1).error_on(:share_page_records)
  end

  it 'has a share_flow virtual attributes' do
    Plink::RegistrationLinkRecord.new.respond_to? :share_flow
  end

  it { should have_one(:affiliate_record) }
  it { should have_one(:campaign_record) }

  it { should have_many(:registration_link_landing_page_records) }
  it { should have_many(:landing_page_records).through(:registration_link_landing_page_records) }

  it { should have_many(:registration_link_share_page_records) }
  it { should have_many(:share_page_records).through(:registration_link_share_page_records) }

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

  describe '#live?' do
    let(:registration_link_record) { new_registration_link }

    it 'returns true if today is between the start_date and end_date' do
      registration_link_record.start_date = 1.day.ago
      registration_link_record.end_date = 1.day.from_now
      registration_link_record.live?.should be_true
    end

    it 'returns true if today is on the start_date' do
      registration_link_record.start_date = Time.zone.now.to_date
      registration_link_record.live?.should be_true
    end

    it 'returns true if today is on end_date' do
      registration_link_record.end_date = Time.zone.now.to_date
      registration_link_record.live?.should be_true
    end

    it 'returns false if today is before the start_date' do
      registration_link_record.start_date = 1.day.from_now

      registration_link_record.live?.should be_false
    end

    it 'returns false if today is after the end_date' do
      registration_link_record.end_date = 1.day.ago

      registration_link_record.live?.should be_false
    end
  end

  describe '#share_flow?' do
    let(:registration_link_record) { new_registration_link }

    it 'returns true if there are share page records' do
      registration_link_record.stub(:share_page_records).and_return([double])

      registration_link_record.share_flow?.should be_true
    end

    it 'returns true if there are not share page records but the virtual attribute is set' do
      registration_link_record.stub(:share_page_records).and_return([double])
      registration_link_record.share_flow = 'true'

      registration_link_record.share_flow?.should be_true
    end

    it 'returns false if there are not share page records' do
      registration_link_record.stub(:share_page_records).and_return([])

      registration_link_record.share_flow?.should be_false
    end
  end
end
