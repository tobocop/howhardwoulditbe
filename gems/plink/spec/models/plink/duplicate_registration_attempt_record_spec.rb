require 'spec_helper'

describe Plink::DuplicateRegistrationAttemptRecord do

  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:existing_user_id) }

  let(:valid_params) do
    {
      user_id: 7,
      existing_user_id: 1
    }
  end

  subject { Plink::DuplicateRegistrationAttemptRecord.new(valid_params) }

  it 'can be persisted' do
    Plink::DuplicateRegistrationAttemptRecord.create(valid_params).should be_persisted
  end

  it 'is invalid without a user_id' do
    Plink::DuplicateRegistrationAttemptRecord.create(existing_user_id: 1).should_not be_valid
  end

  it 'is invalid without an exisiting_user_id' do
    Plink::DuplicateRegistrationAttemptRecord.create(user_id: 1).should_not be_valid
  end

end
