require 'spec_helper'

describe Plink::GlobalLoginTokenRecord do
  let!(:valid_record) {
    create_global_login_token(
      expires_at: 7.days.from_now,
      redirect_url: 'http://awesome.com'
    )
  }

  describe 'validations' do
    it 'validates uniqueness of token scoped to unexpired records' do
      new_record = new_global_login_token(
        expires_at: 2.days.from_now,
        token: valid_record.token
      )

      new_record.should_not be_valid
      new_record.should have(1).error_on(:token)
    end

    it 'does not validate uniquness of token against expired records' do
      expired_record = create_global_login_token(expires_at: 2.days.ago)

      valid_record = new_global_login_token(
        expires_at: 2.days.from_now,
        token: expired_record.token
      )

      valid_record.should be_valid
    end

    it 'must expire within the next 14 days' do
      global_login_token = new_global_login_token(expires_at: 15.days.from_now)
      global_login_token.should_not be_valid
      global_login_token.should have(1).error_on(:expires_at)

      global_login_token.expires_at = 14.days.from_now
      global_login_token.should be_valid
    end
  end

  describe 'named scopes' do
    describe '.existing' do
      it 'returns an empty collection if there are no existing records' do
        Plink::GlobalLoginTokenRecord.existing('nothing').should be_empty
      end

      it 'returns an empty collection if the records for the given token have expired' do
        global_login_token_record = create_global_login_token(expires_at: 10.days.ago)
        token = global_login_token_record.token
        Plink::GlobalLoginTokenRecord.existing(token).should be_empty
      end

      it 'returns GlobalLoginTokenRecords if there exists records for the given token' do
        global_login_token_record = create_global_login_token(expires_at: 10.days.from_now)
        token = global_login_token_record.token
        Plink::GlobalLoginTokenRecord.existing(token).first.id.should == global_login_token_record.id
      end
    end
  end
end
