require 'spec_helper'

describe Plink::UsersInstitutionRecord do
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:institution_id) }
  it { should allow_mass_assignment_of(:intuit_institution_login_id) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:hash_check) }

  it { should validate_presence_of(:hash_check) }
  it { should validate_presence_of(:institution_id) }
  it { should validate_presence_of(:intuit_institution_login_id) }
  it { should validate_presence_of(:is_active) }
  it { should validate_presence_of(:user_id) }

  let(:valid_params) {
    {
      institution_id: 3,
      intuit_institution_login_id: 23,
      is_active: true,
      hash_check: 'my unique hash',
      user_id: 3
    }
  }

  subject { Plink::UsersInstitutionRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it { should belong_to(:institution_record) }
  it { should have_many(:users_institution_account_records) }

  it 'can be persisted' do
    create_users_institution(valid_params).should be_persisted
  end

  it 'can have an institution' do
    institution = create_institution
    users_institution = create_users_institution(valid_params.merge(institution_id: institution.id))
    users_institution.institution_record.should be
  end

end
