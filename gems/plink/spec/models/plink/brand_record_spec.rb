require 'spec_helper'

describe Plink::BrandRecord do
  it { should allow_mass_assignment_of(:brand_competitors_attributes) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:prospect) }
  it { should allow_mass_assignment_of(:sales_rep_id) }
  it { should allow_mass_assignment_of(:vanity_url) }

  it { should belong_to(:sales_rep) }
  it { should have_many(:brand_competitors) }
  it { should have_many(:competitors).through(:brand_competitors) }

  it { should accept_nested_attributes_for(:brand_competitors).allow_destroy(true) }

  let(:valid_params) {
    {
      name: 'Taco derp',
      prospect: false,
      sales_rep_id: 1,
      vanity_url: 'TD'
    }
  }

  it 'can be persisted' do
    Plink::BrandRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:sales_rep_id) }
    it { should validate_presence_of(:vanity_url) }
  end
end
