require 'spec_helper'

describe Plink::IntuitAccountService do
  describe '#find_by_user_id' do
    let(:user) { create_user }

    before do
      create_oauth_token(user_id: user.id)
      institution = create_institution(name: 'First bank of derp')
      users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)
      create_users_institution_account(user_id: user.id, name: 'My Awesome bank account', users_institution_id: users_institution.id, account_number_last_four: 1234)
      create_users_institution_account(user_id: user.id, name: 'My Second Awesome bank account', users_institution_id: users_institution.id, account_number_last_four: 4321)
    end

    it 'returns the most recently created active intuit account ' do
      account = subject.find_by_user_id(user.id)

      account.should be_a(Plink::IntuitAccount)

      account.bank_name.should == 'First bank of derp'
      account.account_name.should == 'My Second Awesome bank account 4321'
    end

    it 'returns nil if the user does not have an active intuit account' do
      subject.find_by_user_id(user.id + 1).should == nil
    end
  end

  describe '#user_has_account?' do
    it 'returns true if the user has an active intuit account' do
      Plink::ActiveIntuitAccountRecord.should_receive(:user_has_account?).with(4).and_return(true)

      subject.user_has_account?(4).should == true
    end

    it 'returns false if the user does not have an active intuit account' do
      Plink::ActiveIntuitAccountRecord.should_receive(:user_has_account?).with(5).and_return(false)

      subject.user_has_account?(5).should == false
    end
  end
end
