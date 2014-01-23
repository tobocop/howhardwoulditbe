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

  context 'named scopes' do
    describe '.active_by_user_id' do
      let!(:users_institution_account_record) {
        create_users_institution_account(
          end_date: 1.minute.from_now,
          is_active: true,
          user_id: 39
        )
      }

      it 'returns active records by user_id and end date' do
        active_records = Plink::UsersInstitutionAccountRecord.active_by_user_id(39)
        active_records.length.should == 1
        active_records.first.id.should == users_institution_account_record.id
      end

      it 'does not return records where the user_id is different' do
        Plink::UsersInstitutionAccountRecord.active_by_user_id(1).length.should == 0
      end

      it 'does not return records where the end date is in the past' do
        users_institution_account_record.update_attribute(:end_date, 1.minute.ago)

        Plink::UsersInstitutionAccountRecord.active_by_user_id(39).length.should == 0
      end

      it 'does not return inactive records' do
        users_institution_account_record.update_attribute(:is_active, false)

        Plink::UsersInstitutionAccountRecord.active_by_user_id(39).length.should == 0
      end
    end
  end
end
