require 'spec_helper'

describe Plink::SalesRepRecord do
  it { should allow_mass_assignment_of(:name) }

  let(:valid_params) {
    {
      name: 'Greg Quittin like a Fox'
    }
  }

  it 'can be persisted' do
    Plink::SalesRepRecord.create(valid_params).should be_persisted
  end
end
