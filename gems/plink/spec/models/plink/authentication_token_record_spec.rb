require 'spec_helper'

describe Plink::AuthenticationTokenRecord do
  it { should allow_mass_assignment_of(:token) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      token: 'test',
      user_id: 1
    }
  }

  it 'can be persisted' do
    Plink::AuthenticationTokenRecord.create(valid_params).should be_persisted
  end
end
