require 'spec_helper'

describe Plink::BrandCompetitorRecord do
  it { should allow_mass_assignment_of(:brand_id) }
  it { should allow_mass_assignment_of(:competitor) }
  it { should allow_mass_assignment_of(:competitor_id) }
  it { should allow_mass_assignment_of(:default) }

  it { should belong_to(:brand) }
  it { should belong_to(:competitor) }

  let(:valid_params) {
    {
      brand_id: 1,
      competitor_id: 3,
      default: false
    }
  }

  it 'can be persisted' do
    Plink::BrandCompetitorRecord.create!(valid_params).should be_persisted
  end
end
