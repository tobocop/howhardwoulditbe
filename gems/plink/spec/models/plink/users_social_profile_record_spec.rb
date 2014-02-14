require 'spec_helper'

describe Plink::UsersSocialProfileRecord do
  it { should allow_mass_assignment_of(:profile)}
  it { should allow_mass_assignment_of(:user_id)}

  let(:valid_params) {
    {
      profile: '{"some":2, "json":3}',
      user_id: 12
    }
  }

  it 'can be persisted' do
    Plink::UsersSocialProfileRecord.create(valid_params).should be_persisted
  end
end
