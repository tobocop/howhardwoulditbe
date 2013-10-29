require 'spec_helper'

describe Plink::UserIntuitErrorRecord do
  it { should allow_mass_assignment_of(:intuit_error_id) }
  it { should allow_mass_assignment_of(:users_institution_id) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params){
    {
      intuit_error_id: 1,
      users_institution_id: 234,
      user_id: 14
    }
  }

  it 'can be persisted' do
    Plink::UserIntuitErrorRecord.create(valid_params).should be_persisted
  end
end
