require 'spec_helper'

describe Plink::UsersInstitutionAccount do

  let (:valid_params) {
    {
      account_id: 1,
      begin_date: Date.yesterday,
      end_date: '2999-12-31',
      user_id: 24,
      users_institution_account_staging_id: 0,
      users_institution_id: 0,
      is_active: true,
      in_intuit: true
    }
  }

  subject { Plink::UsersInstitutionAccount.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    Plink::UsersInstitutionAccount.create(valid_params).should be_persisted
  end


end