require 'spec_helper'

describe 'contest:daily_reminder_email', skip_in_build: true do
  include_context 'rake'

  let!(:contest) { create_contest }
  let!(:user) { create_user(daily_contest_reminder: true) }
  let(:opted_out_user) { create_user(daily_contest_reminder: false, email: 'opted_out@example.com') }
  let(:unselected_user) { create_user(daily_contest_reminder: nil, email: 'unselected@example.com') }
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

describe 'contest:three_day_reminder_email', skip_in_build: true do
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

describe 'contest:create_prize_levels_for_contest', skip_in_build: true do
  include_context 'rake'

  it 'requires a contest id argument' do
    expect {
      subject.invoke
    }.to raise_error ArgumentError
  end

  context 'contest_id 1' do
    it 'creates 1 prize for $250' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 250)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 1
    end

    it 'creates 1 prize for $100' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 100)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 1
    end

    it 'creates 1 prize for $50' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 50)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 1
    end

    it 'creates 1 prize for $20' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 20)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 1
    end

    it 'creates 16 prizes for 10' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 10)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 16
    end

    it 'creates 60 prizes for $5' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 5)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 60
    end

    it 'creates 50 prizes for $2' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 2)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 50
    end

    it 'creates 20 prizes for $1' do
      subject.invoke(1)

      prize_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: 1)
      prize_levels.count.should == 1
      prize_levels.first.award_count.should == 20
    end

    it 'creates a total of 150 prizes' do
      subject.invoke(1)

      Plink::ContestPrizeLevelRecord.sum(:award_count).should == 150
    end

    it 'creates $1000 worth of prizes' do
      subject.invoke(1)

      Plink::ContestPrizeLevelRecord.sum('dollar_amount * award_count').should == 1000
    end
  end

  context 'contest_id 2' do
    let(:prize_levels) {
      [
        {dollar_amount: 350, number_of_winners: 1},
        {dollar_amount: 100, number_of_winners: 1},
        {dollar_amount: 50, number_of_winners: 1},
        {dollar_amount: 25, number_of_winners: 1},
        {dollar_amount: 5, number_of_winners: 20},
        {dollar_amount: 2, number_of_winners: 50},
        {dollar_amount: 1, number_of_winners: 76},
      ]
    }

    it 'creates the prize levels for contest 2' do
      subject.invoke(2)

      prize_levels.each do |prize_level|
        created_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: prize_level[:dollar_amount])
        created_levels.count.should == 1
        created_levels.first.award_count.should == prize_level[:number_of_winners]
      end
    end

    it 'creates $801 worth of prizes' do
      subject.invoke(2)

      Plink::ContestPrizeLevelRecord.sum('dollar_amount * award_count').should == 801
    end
  end

  context 'contest_id 3' do
    let(:prize_levels) {
      [
        {dollar_amount: 500, number_of_winners: 1},
        {dollar_amount: 100, number_of_winners: 1},
        {dollar_amount: 25, number_of_winners: 5},
        {dollar_amount: 5, number_of_winners: 23},
        {dollar_amount: 2, number_of_winners: 40},
        {dollar_amount: 1, number_of_winners: 80}
      ]
    }

    it 'creates the prize levels for contest 3' do
      subject.invoke(3)

      prize_levels.each do |prize_level|
        created_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: prize_level[:dollar_amount])
        created_levels.count.should == 1
        created_levels.first.award_count.should == prize_level[:number_of_winners]
      end
    end

    it 'creates $1000 worth of prizes' do
      subject.invoke(3)

      Plink::ContestPrizeLevelRecord.sum('dollar_amount * award_count').should == 1000
    end
  end
end

describe 'contest:select_winners_for_contest', skip_in_build: true, flaky: true do
  include_context 'rake'

  it 'requires a contest_id argument' do
    expect {
      subject.invoke
    }.to raise_error ArgumentError
  end

  it 'requires at least 300 entrants be present' do
    expect {
      subject.invoke(1)
    }.to raise_error "ERROR: Less than 300 entrants present! Cannot pick winners."
  end

  # TODO: find a better way to "integration" test this task
  it 'selects 300 unique, non-plink, non-force-deactivated users and creates 150 winners and 150 alternates' do
    Rake::Task['contest:create_prize_levels_for_contest'].invoke(1)
    contest = create_contest

    302.times do |i|
      user = create_user(email: "stuff_#{i}@somethingunique.com")
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'facebook', multiplier: 1, computed_entries: 2)
    end
    blacklisted_user = create_user(email: "stuff@plink.com")
    create_entry(contest_id: contest.id, user_id: blacklisted_user.id, provider: 'facebook', multiplier: 1, computed_entries: 1)
    create_contest_blacklisted_user(user_id: blacklisted_user.id)
    non_entered_user = create_user(email: 'unique@other.com')

    subject.invoke(contest.id)

    Plink::ContestWinnerRecord.count.should == 300
    Plink::ContestWinnerRecord.where(contest_id: 1).count(:user_id, distinct: true)

    Plink::ContestWinnerRecord.where(prize_level_id: nil).count.should == 150
    Plink::ContestWinnerRecord.where('prize_level_id IS NOT NULL').count.should == 150

    # does not pick blacklisted user_ids addresses
    Plink::ContestWinnerRecord.where(user_id: blacklisted_user.id).should be_empty
    # does not pick users who have not entered
    Plink::ContestWinnerRecord.where(user_id: non_entered_user.id).should be_empty
  end
end

describe 'contest:post_on_winners_behalf', skip_in_build: true do
  include_context 'rake'

  let!(:contest) { create_contest }
  let!(:user) { create_user }

  it 'requires a contest_id argument' do
    expect {
      subject.invoke
    }.to raise_error ArgumentError
  end

  context 'with a successful call to Gigya' do
    it 'logs it' do
      create_contest_winner(user_id: user.id, contest_id: contest.id, winner: true, finalized_at: 1.minute.ago, prize_level_id: 2)
      gigya_response = double(error_code: 0, status_code: 200)

      Gigya.any_instance.stub(:set_facebook_status).with(anything, /\/facebook_winning_entry_post/).
        and_return(gigya_response)

      output = capture_stdout { subject.invoke(contest.id) }
      output.should =~ /POSTING TO GIGYA: user_id: /
      output.should =~ /SUCCESSFUL POST TO GIGYA:/
    end
  end

  context 'with a failed request' do
    it 'logs the status code and error code' do
      create_contest_winner(user_id: user.id, contest_id: contest.id, winner: true, finalized_at: 1.hour.ago, prize_level_id: 2)
      gigya_response = double(error_code: 1, status_code: 400)
      Gigya.any_instance.stub(:set_facebook_status).and_return(gigya_response)

      output = capture_stdout { subject.invoke(contest.id) }
      output.should =~ /POSTING TO GIGYA:/
      output.should =~ /LOGGED ERRORS: error_code: 1 status_code: 400/
    end
  end
end


