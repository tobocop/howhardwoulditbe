require 'spec_helper'

describe Plink::UsersInstitutionRecord do
  let(:valid_params) {
    {
      institution_id: 3,
      intuit_institution_login_id: 23,
      hash_check: 'my unique hash',
      user_id: 3
    }
  }

  subject { Plink::UsersInstitutionRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    create_users_institution(valid_params).should be_persisted
  end

  it 'can have an institution' do
    institution = create_institution
    users_institution = create_users_institution(valid_params.merge(institution_id: institution.id))
    users_institution.institution_record.should be
  end

end