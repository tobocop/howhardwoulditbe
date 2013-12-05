require 'spec_helper'

describe Plink::UsersInstitutionAccountRecord do

  it { should allow_mass_assignment_of(:account_id) }
  it { should allow_mass_assignment_of(:account_number_hash) }
  it { should allow_mass_assignment_of(:account_number_last_four) }
  it { should allow_mass_assignment_of(:account_type) }
  it { should allow_mass_assignment_of(:account_type_description) }
  it { should allow_mass_assignment_of(:aggr_attempt_date) }
  it { should allow_mass_assignment_of(:aggr_status_code) }
  it { should allow_mass_assignment_of(:aggr_success_date) }
  it { should allow_mass_assignment_of(:begin_date) }
  it { should allow_mass_assignment_of(:currency_code) }
  it { should allow_mass_assignment_of(:end_date) }
  it { should allow_mass_assignment_of(:in_intuit) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:users_institution_account_staging_id) }
  it { should allow_mass_assignment_of(:users_institution_id) }

  let (:valid_params) {
    {
      account_id: 1,
      account_number_hash: 'abc',
      account_number_last_four: 2354,
      account_type: 'creditcard',
      account_type_description: 'My Creditcard',
      aggr_attempt_date: 1.day.ago,
      aggr_status_code: 0,
      aggr_success_date: 1.day.ago,
      begin_date: 1.day.ago,
      currency_code: 'USD',
      end_date: '2999-12-31',
      in_intuit: true,
      is_active: true,
      name: 'account name',
      user_id: 24,
      users_institution_account_staging_id: 0,
      users_institution_id: 0
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
