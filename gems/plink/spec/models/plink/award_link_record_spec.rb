require 'spec_helper'

describe Plink::AwardLinkRecord do
  it { should allow_mass_assignment_of(:award_type_id) }
  it { should allow_mass_assignment_of(:dollar_award_amount) }
  it { should allow_mass_assignment_of(:end_date) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:redirect_url) }
  it { should allow_mass_assignment_of(:start_date) }
  it { should allow_mass_assignment_of(:url_value) }

  let(:valid_params) {
    {
      award_type_id: 2,
      dollar_award_amount: 2.34,
      end_date: 1.day.from_now,
      is_active: true,
      name: 'derp',
      redirect_url: 'http://google.com',
      start_date: 1.day.ago
    }
  }

  it 'can be persisted' do
    Plink::AwardLinkRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:redirect_url) }
  end

  it 'sets a url_value before being created' do
    award_link_record = Plink::AwardLinkRecord.new(valid_params)
    award_link_record.url_value.should be_nil
    award_link_record.save
    award_link_record.url_value.should_not be_nil
  end
end
