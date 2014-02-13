require 'spec_helper'

describe Plink::UsersInstitutionRecord do
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:institution_id) }
  it { should allow_mass_assignment_of(:intuit_institution_login_id) }
  it { should allow_mass_assignment_of(:is_active) }
  it { should allow_mass_assignment_of(:user_id) }
  it { should allow_mass_assignment_of(:hash_check) }

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

  context 'validations' do
    it { should validate_presence_of(:hash_check) }
    it { should validate_presence_of(:institution_id) }
    it { should validate_presence_of(:intuit_institution_login_id) }
    it { should validate_presence_of(:user_id) }
    it { should ensure_inclusion_of(:is_active).in_array([true, false]) }

    # describe 'is_active' do
    #   let(:users_institution_record) { Plink::UsersInstitutionRecord.new(valid_params.except(:is_active)) }

    #   it 'should be valid if active is true' do
    #     users_institution_record.is_active = true

    #     users_institution_record.should be_valid
    #   end

    #   it 'should be valid if active is false' do
    #     users_institution_record.is_active = false

    #     users_institution_record.should be_valid
    #   end

    #   it 'should not be valid if is active is nil' do
    #     users_institution_record.is_active = nil

    #     users_institution_record.should_not be_valid
    #     users_institution_record.should have(1).error_on(:is_active)
    #   end
    # end
  end

  context 'named scopes' do
    describe '.duplicates' do
      let!(:users_institution) { create_users_institution(hash_check: 'my_hash', institution_id: 6, is_active: true, user_id: 3) }

      subject(:duplicates) { Plink::UsersInstitutionRecord.duplicates('my_hash', 6, 93) }

      it 'returns the record if the record exists by institution_id, hash_check, and the user_id is different then the one passed in' do
        duplicates.length.should == 1
      end

      it 'returns nothing if the record is not active' do
        users_institution.update_attribute('is_active', false)
        duplicates.length.should == 0
      end

      it 'returns nothing if the hash_check does not match' do
        users_institution.update_attribute('hash_check', 'nope')
        duplicates.length.should == 0
      end

      it 'returns nothing if the institution_id does not match' do
        users_institution.update_attribute('institution_id', 93)
        duplicates.length.should == 0
      end

      it 'returns nothing if the user_id is the same as the one passed in' do
        users_institution.update_attribute('user_id', 93)
        duplicates.length.should == 0
      end
    end
  end

  it 'can have an institution' do
    institution = create_institution
    users_institution = create_users_institution(valid_params.merge(institution_id: institution.id))
    users_institution.institution_record.should be
  end

  describe 'named scopes' do
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

    describe '.find_by_user_id' do
      let!(:users_institution_record) { create_users_institution(user_id: 3) }

      subject(:users_institution) { Plink::UsersInstitutionRecord }

      it 'returns records by user_id' do
        users_institution.find_by_user_id(3).first.id.should == users_institution_record.id
      end

      it 'does not return records where the user_id does not match' do
        users_institution.find_by_user_id(4).should == []
      end
    end
  end
end
