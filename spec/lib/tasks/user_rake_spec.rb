require 'spec_helper'

describe 'user:backfill_registration_provider', skip_in_build: true do
  include_context 'rake'

  let!(:user_with_facebook) {
    user = create_user(fbUserID: 1234, email: 'facebook@example.com')
    user.update_attribute(:provider, nil)
    user
  }
  let!(:user_without_facebook) {
    user = create_user(fbUserID: nil, email: 'no_facebook@example.com')
    user.update_attribute(:provider, nil)
    user
  }

  before { subject.invoke }

  it 'sets the provider to Facebook for users with a Facebook user id' do
    user_with_facebook.reload.provider.should == 'facebook'
  end

  it 'sets the provider to organic for users without a facebook id' do
    user_without_facebook.reload.provider.should == 'organic'
  end
end

describe 'user:reset_shortened_referral_link', skip_in_build: true do
  include_context 'rake'

  before :each do
    create_user(shortened_referral_link: 'http://example.com', email: 'user1@example.com')
    create_user(shortened_referral_link: 'http://examples.com', email: 'user2@example.com')
    create_user(email: 'user3@example.com')
  end

  it 'sets the shortened_referral_link for all users to null' do
    subject.invoke

    Plink::UserRecord.all.each do |user|
      user.shortened_referral_link.should be_nil
    end
  end
end

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
