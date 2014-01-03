require 'spec_helper'

describe Plink::UsersInstitutionService do
  describe '.users_institution_registered?' do
    subject(:users_institution_registered?) {
      Plink::UsersInstitutionService.users_institution_registered?('string', 1, 4)
    }

    context 'when there is a duplicate' do
      before do
        Plink::UsersInstitutionRecord.stub(:duplicates).and_return([double(id: 1), double(id: 7)])
      end

      it 'returns true' do
        users_institution_registered?.should be_true
      end

      it 'logs the occurance of a duplicate' do
        Plink::DuplicateRegistrationAttemptRecord.should_receive(:create).with({
          existing_users_institution_id: 1,
          user_id: 4
        })
        Plink::DuplicateRegistrationAttemptRecord.should_receive(:create).with({
          existing_users_institution_id: 7,
          user_id: 4
        })

        users_institution_registered?
      end
    end

    context 'when there is not a duplicate' do
      before do
        Plink::UsersInstitutionRecord.stub(:duplicates).and_return([])
      end

      it 'returns false' do
        users_institution_registered?.should be_false
      end
    end
  end
end
