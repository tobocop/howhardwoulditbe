require 'spec_helper'

describe Plink::ActiveIntuitAccountRecord do

  let(:user) { create_user }

  before do
    create_oauth_token(user_id: user.id)
    institution = create_institution(name: 'First bank of derp')
    users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
    create_users_institution_account(user_id: user.id, name: 'My Awesome bank account', users_institution_id: users_institution.id, account_number_last_four: 5468)
  end

  describe 'self.has_account?(user_id)' do

    it 'returns false if there is no record with the given user id' do
      Plink::ActiveIntuitAccountRecord.user_has_account?(100).should == false
    end

    it 'returns true if there is a record for the given user id' do
      Plink::ActiveIntuitAccountRecord.user_has_account?(user.id).should == true
    end
  end

  it 'can return its attributes' do
    Plink::ActiveIntuitAccountRecord.first.user_id.should == user.id
  end

  it 'can give back names of its associations' do
    active_intuit_account = Plink::ActiveIntuitAccountRecord.first
    active_intuit_account.account_name.should == 'My Awesome bank account'
    active_intuit_account.bank_name.should == 'First bank of derp'
  end

  it 'can return the last 4 nubmers of an account' do
    active_intuit_account = Plink::ActiveIntuitAccountRecord.first
    active_intuit_account.account_number_last_four.should == '5468'
  end

end
