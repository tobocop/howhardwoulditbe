require 'spec_helper'

describe Plink::UsersInstitutionAccountStagingRecord do
  it { should validate_presence_of(:account_id) }
  it { should validate_presence_of(:user_id) }
  it { should validate_presence_of(:users_institution_id) }

  it { should allow_mass_assignment_of(:account_id) }
  it { should allow_mass_assignment_of(:account_number_hash) }
  it { should allow_mass_assignment_of(:account_number_last_four) }
  it { should allow_mass_assignment_of(:account_type) }
  it { should allow_mass_assignment_of(:account_type_description) }
  it { should allow_mass_assignment_of(:aggr_attempt_date) }
  it { should allow_mass_assignment_of(:aggr_status_code) }
  it { should allow_mass_assignment_of(:aggr_success_date) }
  it { should allow_mass_assignment_of(:currency_code) }
  it { should allow_mass_assignment_of(:in_intuit) }
  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:status) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:users_institution_id) }

  let(:current_time) { Time.zone.now }
  let (:valid_params) {
    {
      account_id: 1,
      account_number_hash: '1234ASDHcmasdh5948',
      account_number_last_four: '7890',
      account_type: nil,
      account_type_description: 'LINEOFCREDIT',
      aggr_attempt_date: current_time,
      aggr_status_code: '123',
      aggr_success_date: current_time,
      currency_code: 'USD',
      in_intuit: true,
      name: 'account name',
      status: 'ACTIVE',
      user_id: 24,
      users_institution_id: 0
    }
  }

  subject(:users_institution_account_staging) { Plink::UsersInstitutionAccountStagingRecord.new(valid_params) }

  it_should_behave_like(:legacy_timestamps)

  it 'can be persisted' do
    record = Plink::UsersInstitutionAccountStagingRecord.create(valid_params)
    record.should be_persisted
    record.name.should == 'account name'
  end

  describe '#values_for_final_account' do
    before { users_institution_account_staging.save! }

    it 'returns a hash' do
      users_institution_account_staging.values_for_final_account.should be_a Hash
    end

    it 'returns the correct values do' do
      users_institution_account_staging.values_for_final_account.should == {
        account_id: 1,
        account_number_hash: '1234ASDHcmasdh5948',
        account_number_last_four: '7890',
        account_type: nil,
        account_type_description: 'LINEOFCREDIT',
        aggr_attempt_date: current_time,
        aggr_status_code: '123',
        aggr_success_date: current_time,
        begin_date: Date.current,
        currency_code: 'USD',
        end_date: 100.years.from_now.to_date,
        in_intuit: true,
        name: 'account name',
        user_id: 24,
        users_institution_account_staging_id: users_institution_account_staging.id,
        users_institution_id: 0
      }
    end
  end
end
