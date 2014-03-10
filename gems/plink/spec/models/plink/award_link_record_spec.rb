require 'spec_helper'

describe Plink::AwardLinkRecord do
  it { should allow_mass_assignment_of(:award_type_id) }
  it { should allow_mass_assignment_of(:dollar_award_amount) }
  it { should allow_mass_assignment_of(:end_date) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:redirect_url) }
  it { should allow_mass_assignment_of(:start_date) }
  it { should allow_mass_assignment_of(:url_value) }

  let(:valid_params) {
    {
      award_type_id: 2,
      dollar_award_amount: 2.34,
      end_date: 1.day.from_now,
      is_active: true,
      redirect_url: 'http://google.com',
      start_date: 1.day.ago,
      url_value: 'something'
    }
  }

  it 'can be persisted' do
    Plink::AwardLinkRecord.create(valid_params).should be_persisted
  end
end
