require 'spec_helper'

describe Plink::ContactRecord do
  it { should allow_mass_assignment_of(:brand_id) }
  it { should allow_mass_assignment_of(:email) }
  it { should allow_mass_assignment_of(:first_name) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:last_name) }

  it { should belong_to(:brand) }

  let(:valid_params) {
    {
      brand_id: 2,
      email: 'test@herewego.com',
      first_name: 'first',
      is_active: true,
      last_name: 'last'
    }
  }

  it 'can be persisted' do
    Plink::ContactRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:brand_id) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
  end
end
