require 'spec_helper'

describe ContestNotification do
  describe '.for_user' do
    let!(:contest) { create_contest }
    let(:user) { create_user }

    it 'returns nil for users who have already entered today' do
      create_entry(contest_id: contest.id, user_id: user.id)
      ContestNotification.for_user(user.id).should == {}
    end

    it "returns 'enter_today' for users who have not entered today" do
      ContestNotification.for_user(user.id)[:partial].should == 'enter_today'
    end

    it "returns 'contest_winner' for users who have entered a now-finalized contest" do
      contest.update_attributes(end_time: 1.day.ago, finalized_at: 1.minute.ago)
      prize_level = create_contest_prize_level(dollar_amount: 25)
      create_contest_winner(user_id: user.id, contest_id: contest.id, prize_level_id: prize_level.id)

      notification = ContestNotification.for_user(user.id)
      notification[:partial].should == 'contest_winner'
      notification[:points].should == 2500
    end

    it 'returns the notification for a specific contest if an optional contest_id is provided' do
      Plink::ContestRecord.stub(:last_finalized).and_return(nil)
      contest.update_attributes(end_time: 1.day.ago)

      notification = ContestNotification.for_user(user.id, contest.id)
      notification[:partial].should == 'contest_winner'
    end
  end
end
