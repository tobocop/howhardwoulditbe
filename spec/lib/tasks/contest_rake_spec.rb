require 'spec_helper'

describe 'contest:daily_reminder_email', skip_in_build: true do
  include_context 'rake'

  let!(:contest) { create_contest }
  let!(:contest_email) {
      create_contest_email(
        contest_id: contest.id,
        day_one_preview: 'sneak peak',
        day_one_subject: 'enter now enter now',
        day_one_body: 'daily reminder to enter this sweet contest',
        day_one_link_text: 'link to here',
        day_one_image: 'http://www.baconmockup.com/400/400'
      )
    }
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

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
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

  context 'when there are exceptions' do
    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      create_entry(contest_id: contest.id, user_id: user.id, created_at: 1.day.ago)
      ContestMailer.stub(:daily_reminder_email).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /daily_reminder_email/
      end

      subject.invoke
    end

    it 'includes the user.id in the record-level exception text' do
      create_entry(contest_id: contest.id, user_id: user.id, created_at: 1.day.ago)
      ContestMailer.stub(:daily_reminder_email).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /user\.id = \d+/
      end

      subject.invoke
    end

    it 'logs Rake task-level exceptions to Exceptional with the Rake task name' do
      Plink::UserRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /daily_reminder_email/
      end

      subject.invoke
    end

    it 'does not include user.id in task-level exceptions' do
      Plink::UserRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id =/)

      subject.invoke
    end
  end
end

describe 'contest:three_day_reminder_email', skip_in_build: true do
  include_context 'rake'

  let!(:contest) { create_contest }
  let!(:contest_email) {
      create_contest_email(
        contest_id: contest.id,
        three_day_preview: 'sneak peak',
        three_day_subject: 'enter now enter now',
        three_day_body: 'daily reminder to enter this sweet contest',
        three_day_link_text: 'link to here',
        three_day_image: 'http://www.baconmockup.com/400/400'
      )
    }
  let(:user) { create_user(daily_contest_reminder: true) }
  let!(:opted_out_user) { create_user(email: 'opt-out@plink.com', daily_contest_reminder: false) }
  let!(:user_without_preference) { create_user(email: 'nopref@plink.com', daily_contest_reminder: nil) }

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

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

  context 'when there are exceptions' do
    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      create_entry(contest_id: contest.id, user_id: user.id, created_at: 3.days.ago)
      ContestMailer.stub(:three_day_reminder_email).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /three_day_reminder_email/
      end

      subject.invoke
    end

    it 'includes the user.id in the record-level exception text' do
      create_entry(contest_id: contest.id, user_id: user.id, created_at: 3.days.ago)
      ContestMailer.stub(:three_day_reminder_email).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /user\.id = \d+/
      end

      subject.invoke
    end

    it 'logs Rake task-level exceptions to Exceptional with the Rake task name' do
      Plink::UserRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /three_day_reminder_email/
      end

      subject.invoke
    end

    it 'does not include user.id in task-level exceptions' do
      Plink::UserRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id =/)

      subject.invoke
    end
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

  context 'contest_id 4' do
    let(:prize_levels) {
      [
        {dollar_amount: 440, number_of_winners: 1},
        {dollar_amount: 100, number_of_winners: 1},
        {dollar_amount: 50, number_of_winners: 1},
        {dollar_amount: 5, number_of_winners: 5},
        {dollar_amount: 2, number_of_winners: 42},
        {dollar_amount: 1, number_of_winners: 100}
      ]
    }

    it 'creates the prize levels for contest 4' do
      subject.invoke(4)

      prize_levels.each do |prize_level|
        created_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: prize_level[:dollar_amount])
        created_levels.count.should == 1
        created_levels.first.award_count.should == prize_level[:number_of_winners]
      end
    end

    it 'creates $799 worth of prizes' do
      subject.invoke(4)

      Plink::ContestPrizeLevelRecord.sum('dollar_amount * award_count').should == 799
    end
  end

  context 'contest_id 5' do
    let(:prize_levels) {
      [
        {dollar_amount: 400, number_of_winners: 1},
        {dollar_amount: 100, number_of_winners: 1},
        {dollar_amount: 25, number_of_winners: 7},
        {dollar_amount: 10, number_of_winners: 10},
        {dollar_amount: 5, number_of_winners: 12},
        {dollar_amount: 2, number_of_winners: 45},
        {dollar_amount: 1, number_of_winners: 74}
      ]
    }

    it 'creates the prize levels for contest 5' do
      subject.invoke(5)

      prize_levels.each do |prize_level|
        created_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: prize_level[:dollar_amount])
        created_levels.count.should == 1
        created_levels.first.award_count.should == prize_level[:number_of_winners]
      end
    end

    it 'creates $999 worth of prizes' do
      subject.invoke(5)

      Plink::ContestPrizeLevelRecord.sum('dollar_amount * award_count').should == 999
    end
  end

  context 'contest_id 6' do
    let(:prize_levels) {
      [
        {dollar_amount: 500, number_of_winners: 1},
        {dollar_amount: 25, number_of_winners: 7},
        {dollar_amount: 10, number_of_winners: 10},
        {dollar_amount: 5, number_of_winners: 12},
        {dollar_amount: 2, number_of_winners: 45},
        {dollar_amount: 1, number_of_winners: 75}
      ]
    }

    it 'creates the prize levels for contest 6' do
      subject.invoke(6)

      prize_levels.each do |prize_level|
        created_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: prize_level[:dollar_amount])
        created_levels.count.should == 1
        created_levels.first.award_count.should == prize_level[:number_of_winners]
      end
    end

    it 'creates $1000 worth of prizes' do
      subject.invoke(6)

      Plink::ContestPrizeLevelRecord.sum('dollar_amount * award_count').should == 1000
    end
  end

  context 'contest_id 7' do
    let(:prize_levels) {
      [
        {dollar_amount: 635, number_of_winners: 1},
        {dollar_amount: 25, number_of_winners: 4},
        {dollar_amount: 10, number_of_winners: 6},
        {dollar_amount: 5, number_of_winners: 8},
        {dollar_amount: 2, number_of_winners: 34},
        {dollar_amount: 1, number_of_winners: 97}
      ]
    }

    it 'creates the prize levels for contest 7' do
      subject.invoke(7)

      prize_levels.each do |prize_level|
        created_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: prize_level[:dollar_amount])
        created_levels.count.should == 1
        created_levels.first.award_count.should == prize_level[:number_of_winners]
      end
    end

    it 'creates $1000 worth of prizes' do
      subject.invoke(7)

      Plink::ContestPrizeLevelRecord.sum('dollar_amount * award_count').should == 1000
    end
  end

  context 'contest_id 8' do
    let(:prize_levels) {
      [
        {dollar_amount: 500, number_of_winners: 1},
        {dollar_amount: 25, number_of_winners: 7},
        {dollar_amount: 10, number_of_winners: 10},
        {dollar_amount: 5, number_of_winners: 12},
        {dollar_amount: 2, number_of_winners: 45},
        {dollar_amount: 1, number_of_winners: 75}
      ]
    }

    it 'creates the prize levels for contest 8' do
      subject.invoke(8)

      prize_levels.each do |prize_level|
        created_levels = Plink::ContestPrizeLevelRecord.where(dollar_amount: prize_level[:dollar_amount])
        created_levels.count.should == 1
        created_levels.first.award_count.should == prize_level[:number_of_winners]
      end
    end

    it 'creates $1000 worth of prizes' do
      subject.invoke(8)

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

  it 'calls the select contest winning service with the passed in contest id' do
    PlinkAdmin::SelectContestWinnersService.should_receive(:process!).with(3)

    subject.invoke(3)
  end
end

describe 'contest:post_on_winners_behalf', skip_in_build: true do
  include_context 'rake'

  let!(:contest) { create_contest }

  before do
    PlinkAdmin::NotifyContestWinnersService.stub(:notify!)
  end

  it 'requires a contest_id argument' do
    expect {
      subject.invoke
    }.to raise_error ArgumentError
  end

  it 'requires a share_message_argument' do
    expect {
      subject.invoke(contest.id)
    }.to raise_error ArgumentError
  end

  it 'posts the notices to facebook' do
    PlinkAdmin::NotifyContestWinnersService.should_receive(:notify!).with(contest.id, 'winner auto post')

    subject.invoke(contest.id, 'winner auto post')
  end
end
