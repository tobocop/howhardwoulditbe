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

  describe 'scopes' do
    describe '.unchosen_accounts_in_intuit' do
      let!(:unchosen_account) { create_users_institution_account_staging(
          account_id: 123,
          created: 3.days.ago,
          in_intuit: true
        )
      }

      subject(:unchosen_accounts_in_intuit) { Plink::UsersInstitutionAccountStagingRecord.unchosen_accounts_in_intuit }

      it 'returns unchosen accounts that are not end dated' do
        create_users_institution_account(account_id: unchosen_account.account_id, end_date: 4.days.ago)

        unchosen_accounts_in_intuit.should == [unchosen_account]
      end

      it 'does not return chosen accounts that were end dated less than 3 days ago' do
        create_users_institution_account(account_id: unchosen_account.account_id, end_date: 2.days.ago)

        unchosen_accounts_in_intuit.should == []
      end

      it 'does not return chosen accounts' do
        create_users_institution_account(account_id: unchosen_account.account_id)

        unchosen_accounts_in_intuit.should == []
      end

      it 'does not return accounts unless they are 2 days old' do
        unchosen_account.update_attribute('created', 1.day.ago)

        unchosen_accounts_in_intuit.should == []
      end

      it 'does not return accounts that are not in intuit' do
        unchosen_account.update_attribute('inIntuit', false)

        unchosen_accounts_in_intuit.should == []
      end
    end

    describe '.accounts_of_force_deactivated_users' do
      let!(:force_deactivated_user) { create_user(isForceDeactivated: true) }
      let!(:account_to_remove) { create_users_institution_account_staging(user_id: force_deactivated_user.id, in_intuit: true) }

      subject(:accounts_of_force_deactivated_users) { Plink::UsersInstitutionAccountStagingRecord.accounts_of_force_deactivated_users }

      it 'returns all accounts that are associated to force deactivated users' do
        accounts_of_force_deactivated_users.should == [account_to_remove]
      end

      it 'does not return accounts for active users' do
        force_deactivated_user.update_attribute('isForceDeactivated', false)

        accounts_of_force_deactivated_users.should == []
      end

      it 'does not return accounts that are no longer in intuit' do
        account_to_remove.update_attribute('inIntuit', false)

        accounts_of_force_deactivated_users.should == []
      end
    end
  end

  describe '.inactive_intuit_accounts' do
    it 'combines unchosen_accounts_in_intuit and accounts_of_force_deactivated_users' do
      record = double(Plink::UsersInstitutionAccountStagingRecord)

      Plink::UsersInstitutionAccountStagingRecord.should_receive(:unchosen_accounts_in_intuit).and_return([record])
      Plink::UsersInstitutionAccountStagingRecord.should_receive(:accounts_of_force_deactivated_users).and_return([record])

      Plink::UsersInstitutionAccountStagingRecord.inactive_intuit_accounts.should == [record, record]
    end
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
