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
