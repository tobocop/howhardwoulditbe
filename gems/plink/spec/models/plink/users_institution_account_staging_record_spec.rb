require 'spec_helper'

describe Plink::UsersInstitutionAccountStagingRecord do
  let (:valid_params) {
    {
      account_id: 1,
      user_id: 24,
      users_institution_id: 0,
      in_intuit: true,
      name: 'account name',
      account_number_last_four: 2354
    }
  }

  subject { Plink::UsersInstitutionAccountStagingRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    record = Plink::UsersInstitutionAccountStagingRecord.create(valid_params)
    record.should be_persisted
    record.name.should == 'account name'
  end
end
