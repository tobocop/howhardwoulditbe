require 'spec_helper'

describe Plink::CompanyRecord do
  it { should allow_mass_assignment_of(:advertiser_id) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:prospect) }
  it { should allow_mass_assignment_of(:sales_rep_id) }
  it { should allow_mass_assignment_of(:vanity_url) }

  it { should belong_to(:sales_rep) }

  let(:valid_params) {
    {
      advertiser_id: 2,
      name: 'Taco derp',
      prospect: false,
      sales_rep_id: 1,
      vanity_url: 'TD'
    }
  }

  it 'can be persisted' do
    Plink::CompanyRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:advertiser_id) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:sales_rep_id) }
    it { should validate_presence_of(:vanity_url) }
  end
end
