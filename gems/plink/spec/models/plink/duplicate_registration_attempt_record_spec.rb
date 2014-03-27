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

  describe 'scopes' do
    describe '.duplicates_by_user_id' do
      let!(:user) { create_user(first_name: 'bob', email: 'derp@herp.com') }
      let!(:institution) { create_institution(name: 'Bank of representin') }
      let!(:users_institution) { create_users_institution(user_id: user.id, institution_id: institution.id) }
      let!(:duplicate_registration_attempt_record) { create_duplicate_registration_attempt(user_id: user.id, existing_users_institution_id: users_institution.id) }

      subject(:duplicates_by_user_id) { Plink::DuplicateRegistrationAttemptRecord.duplicates_by_user_id(user.id) }

      it 'returns records that match the user_id' do
        duplicates = duplicates_by_user_id
        duplicates.length.should == 1
        duplicates.first.institution_name.should == 'Bank of representin'
        duplicates.first.duplicate_user_id.should == user.id
        duplicates.first.duplicate_user_first_name.should == 'bob'
        duplicates.first.duplicate_user_email.should == 'derp@herp.com'
      end
    end
  end
end
