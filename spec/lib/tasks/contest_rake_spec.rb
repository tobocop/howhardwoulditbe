require 'spec_helper'

describe 'contest:daily_reminder_email' do
  include_context 'rake'

  let!(:contest) { create_contest }
  let!(:user) { create_user(daily_contest_reminder: true) }
  let(:opted_out_user) {create_user(daily_contest_reminder: false, email: 'opted_out@example.com') }
  let(:unselected_user) {create_user(daily_contest_reminder: nil, email: 'unselected@example.com') }
  let(:reminder_args) {
    {
      user_id: user.id,
      first_name: user.first_name,
      email: user.email
    }
  }

  let!(:with_entry_user) do
    user = create_user(email: 'unique@test.com', daily_contest_reminder: true)
    create_entry(contest_id: contest.id, user_id: user.id)
    user
  end

  it 'emails users who have their latest entry as yesterday' do
    create_entry(contest_id: contest.id, user_id: user.id, created_at: 1.day.ago)

    subject.invoke

    ActionMailer::Base.deliveries.should_not be_empty
    ActionMailer::Base.deliveries.first.to.should == [user.email]
  end

  it 'does not email users who have opted out of the emails' do
    create_entry(contest_id: contest.id, user_id: user.id, created_at: 1.day.ago)
    user.update_attribute(:daily_contest_reminder, false)

    ContestMailer.should_not_receive(:daily_reminder_email).with(reminder_args)

    subject.invoke
  end

  it 'does not email users who have not yet entered or selected to receive emails' do
    create_entry(contest_id: contest.id, user_id: user.id, created_at: 1.day.ago)
    user.update_attribute(:daily_contest_reminder, nil)

    ContestMailer.should_not_receive(:daily_reminder_email).with(reminder_args)

    subject.invoke
  end

  it 'does not email users who have not entered yesterday but entered before then' do
    create_entry(contest_id: contest.id, user_id: user.id, created_at: 2.days.ago)

    ContestMailer.should_not_receive(:daily_reminder_email).with(reminder_args)

    subject.invoke
  end

  it 'does not email users who have already entered today' do
    create_entry(contest_id: contest.id, user_id: user.id)

    reminder_args = {
      user_id: user.id,
      first_name: user.first_name,
      email: user.email
    }

    ContestMailer.should_not_receive(:daily_reminder_email).with(reminder_args)

    subject.invoke
  end
end

describe 'contest:three_day_reminder_email' do
  include_context 'rake'

  let(:contest) { create_contest }
  let(:user) { create_user(daily_contest_reminder: true) }
  let!(:opted_out_user) { create_user(email: 'opt-out@plink.com', daily_contest_reminder: false) }
  let!(:user_without_preference) { create_user(email: 'nopref@plink.com', daily_contest_reminder: nil) }

  it 'emails users that entered three days ago and receive daily reminder emails' do
    create_entry(contest_id: contest.id, user_id: user.id, created_at: 3.days.ago)

    subject.invoke

    ActionMailer::Base.deliveries.should_not be_empty
    ActionMailer::Base.deliveries.first.to.should == [user.email]
  end

  it 'does not email users who entered more than three days ago but not since' do
    create_entry(contest_id: contest.id, user_id: user.id, created_at: 4.days.ago)

    subject.invoke

    ActionMailer::Base.deliveries.should be_empty
  end

  it 'does not email users who entered yesterday' do
    create_entry(contest_id: contest.id, user_id: user.id, created_at: 1.day.ago)

    subject.invoke

    ActionMailer::Base.deliveries.should be_empty
  end

  it 'does not email users who have opted out even if they entered 3 days ago' do
    create_entry(contest_id: contest.id, user_id: opted_out_user.id, created_at: 3.days.ago)

    subject.invoke

    ActionMailer::Base.deliveries.should be_empty
  end

  it 'does not email users who have not set a preference' do
    create_entry(contest_id: contest.id, user_id: user_without_preference.id, created_at: 3.days.ago)

    subject.invoke

    ActionMailer::Base.deliveries.should be_empty
  end
end
