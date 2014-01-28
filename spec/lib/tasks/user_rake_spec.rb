require 'spec_helper'

describe 'user:reset_login_tokens' do
  include_context 'rake'

  let!(:first_user) { create_user(email: 'first@plink.com') }
  let!(:second_user) { create_user(email: 'second@plink.com') }

  before do
    first_user.update_attribute('modified', 10.days.ago)
    second_user.update_attribute('modified', 10.days.ago)
  end

  it 'updates all login tokens for users and does not update the modified date' do
    subject.invoke

    updated_first_user = Plink::UserRecord.find(first_user.id)
    updated_second_user = Plink::UserRecord.find(second_user.id)
    updated_first_user.login_token.should_not == first_user.login_token
    updated_first_user.modified.to_date.should == first_user.modified.to_date
    updated_second_user.login_token.should_not == second_user.login_token
    updated_second_user.modified.to_date.should == second_user.modified.to_date
    updated_first_user.login_token.should_not == updated_second_user.login_token
  end
end
