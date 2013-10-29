require 'spec_helper'

describe Plink::IntuitAccountToRemoveRecord do
  it { should allow_mass_assignment_of(:intuit_account_id) }
  it { should allow_mass_assignment_of(:users_institution_id) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      intuit_account_id: 3,
      users_institution_id: 2,
      user_id: 1
    }
  }

  it 'can be persisted' do
    Plink::IntuitAccountToRemoveRecord.create(valid_params).should be_persisted
  end
end
