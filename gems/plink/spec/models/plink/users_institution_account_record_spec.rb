require 'spec_helper'

describe Plink::UsersInstitutionAccountRecord do

  let (:valid_params) {
    {
      account_id: 1,
      begin_date: 1.day.ago,
      end_date: '2999-12-31',
      user_id: 24,
      users_institution_account_staging_id: 0,
      users_institution_id: 0,
      is_active: true,
      in_intuit: true,
      name: 'account name',
      account_number_last_four: 2354
    }
  }

  subject { Plink::UsersInstitutionAccountRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    record = Plink::UsersInstitutionAccountRecord.create(valid_params)
    record.should be_persisted
    record.name.should == 'account name'
  end


end
