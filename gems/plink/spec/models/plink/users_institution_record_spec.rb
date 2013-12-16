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
  it { should have_many(:users_institution_account_staging_records) }

  it 'can be persisted' do
    create_users_institution(valid_params).should be_persisted
  end

  it 'can have an institution' do
    institution = create_institution
    users_institution = create_users_institution(valid_params.merge(institution_id: institution.id))
    users_institution.institution_record.should be
  end

  describe '#all_accounts_in_intuit' do
    let(:users_institution) { create_users_institution }
    let!(:users_institution_account) { create_users_institution_account(users_institution_id: users_institution.id) }
    let!(:users_institution_account_staging) { create_users_institution_account_staging(users_institution_id: users_institution.id) }

    it 'returns all users_institution_accounts and users_institution_accounts_staging_records that still exist in intuit' do
      users_institution.all_accounts_in_intuit.should include(users_institution_account, users_institution_account_staging)
    end

    it 'does not return account records not in intuit' do
      users_institution_account.update_attribute('inIntuit', false)
      intuit_accounts = users_institution.all_accounts_in_intuit
      intuit_accounts.length.should == 1
      intuit_accounts.first.should == users_institution_account_staging
    end

    it 'does not return staged account records not in intuit' do
      users_institution_account_staging.update_attribute('inIntuit', false)
      intuit_accounts = users_institution.all_accounts_in_intuit
      intuit_accounts.length.should == 1
      intuit_accounts.first.should == users_institution_account
    end
  end

  context 'named scopes' do
    describe '.hash_check_duplicates' do

      let!(:users_institution) { create_users_institution }
      let(:scope) { Plink::UsersInstitutionRecord.hash_check_duplicates(users_institution.institution_id, 'my unique hash', 10) }

      it 'returns the matched record' do
        scope.should include users_institution
      end

      it 'does not return invalid records' do
        users_institution.update_attribute(:hash_check, 'higgledy-piggledy')

        scope.should_not include users_institution
      end
    end
  end
end
