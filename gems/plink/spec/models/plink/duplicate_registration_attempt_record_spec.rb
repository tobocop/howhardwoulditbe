require 'spec_helper'

describe Plink::DuplicateRegistrationAttemptRecord do
  it { should allow_mass_assignment_of(:existing_users_institution_id) }
  it { should allow_mass_assignment_of(:user_id) }

  let(:valid_params) {
    {
      existing_users_institution_id: 5,
      user_id: 4
    }
  }

  it 'can be persisted' do
    Plink::DuplicateRegistrationAttemptRecord.create(valid_params).should be_persisted
  end

  describe 'validations' do
    it { should validate_presence_of(:existing_users_institution_id) }
    it { should validate_presence_of(:user_id) }
  end
end
