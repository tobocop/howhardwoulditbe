require 'spec_helper'

describe Plink::UserAutoLoginRecord do
  let!(:valid_record) {
    create_user_auto_login(
      user_id: 1,
      expires_at: 2.days.from_now
    )
  }

  it { should validate_presence_of(:user_id) }

  it 'validates uniqueness of user_token scoped to unexpired records' do
    new_record = new_user_auto_login(
      user_id: 1,
      expires_at: 2.days.from_now,
      user_token: valid_record.user_token
    )

    new_record.should_not be_valid
    new_record.should have(1).error_on(:user_token)
  end

  it 'does not validate uniquness of user_token against expired records' do
    expired_record = create_user_auto_login(
      user_id: 1,
      expires_at: 2.days.ago
    )

    valid_record = new_user_auto_login(
      user_id: 1,
      expires_at: 2.days.from_now,
      user_token: expired_record.user_token
    )

    valid_record.should be_valid
  end

  it { should allow_mass_assignment_of(:expires_at) }
  it { should allow_mass_assignment_of(:user_id) }

  describe 'named scopes' do
    describe '.existing' do
      it 'returns an empty collection if there are no existing records' do
        Plink::UserAutoLoginRecord.existing('nothing').should be_empty
      end

      it 'returns an empty collection if the records for the given user_token have expired' do
        user_auto_login_record = create_user_auto_login(
          expires_at: 10.days.ago
        )

        token = user_auto_login_record.user_token
        Plink::UserAutoLoginRecord.existing(token).should be_empty
      end

      it 'returns UserAutoLoginRecords if there exists records for the given user_token' do
        user_auto_login_record = create_user_auto_login(
          expires_at: 10.days.from_now
        )

        token = user_auto_login_record.user_token
        Plink::UserAutoLoginRecord.existing(token).first.id.should == user_auto_login_record.id
      end
    end
  end
end
