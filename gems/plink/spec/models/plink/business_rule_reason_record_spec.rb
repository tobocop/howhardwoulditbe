require 'spec_helper'

describe Plink::BusinessRuleReasonRecord do
  it { should allow_mass_assignment_of(:description) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:name) }

  let(:valid_params) {
    {
      description: 'this herped all the derps',
      is_active: true,
      name: 'derp'
    }
  }

  it 'can be persisted' do
    Plink::BusinessRuleReasonRecord.create(valid_params).should be_persisted
  end
end
