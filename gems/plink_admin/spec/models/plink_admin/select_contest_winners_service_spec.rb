require 'spec_helper'

describe PlinkAdmin::SelectContestWinnersService do
  describe '.process!' do
    it 'requires at least 300 entrants be present' do
      expect {
        PlinkAdmin::SelectContestWinnersService.process!(1)
      }.to raise_error "ERROR: Less than 300 entrants present! Cannot pick winners."
    end

    # TODO: find a better way to "integration" test this task
    it 'selects 300 unique, non-plink, non-force-deactivated users and creates 150 winners and 150 alternates' do
      contest = create_contest

      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 250, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 100, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 50, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 20, award_count: 1)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 10, award_count: 16)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 5, award_count: 60)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 2, award_count: 50)
      Plink::ContestPrizeLevelRecord.create!(contest_id: contest.id, dollar_amount: 1, award_count: 20)

      302.times do |i|
        user = create_user(email: "stuff_#{i}@somethingunique.com")
        create_entry(contest_id: contest.id, user_id: user.id, provider: 'facebook', multiplier: 1, computed_entries: 2)
      end
      blacklisted_user = create_user(email: "stuff@plink.com")
      create_entry(contest_id: contest.id, user_id: blacklisted_user.id, provider: 'facebook', multiplier: 1, computed_entries: 1)
      create_contest_blacklisted_user(user_id: blacklisted_user.id)
      non_entered_user = create_user(email: 'unique@other.com')

      PlinkAdmin::ContestWinningService.should_receive(:refresh_blacklisted_user_ids!)

      PlinkAdmin::SelectContestWinnersService.process!(contest.id)

      Plink::ContestWinnerRecord.count.should == 300

      Plink::ContestWinnerRecord.where(prize_level_id: nil).count.should == 150
      Plink::ContestWinnerRecord.where('prize_level_id IS NOT NULL').count.should == 150

      # does not pick blacklisted user_ids addresses
      Plink::ContestWinnerRecord.where(user_id: blacklisted_user.id).should be_empty
      # does not pick users who have not entered
      Plink::ContestWinnerRecord.where(user_id: non_entered_user.id).should be_empty
    end
  end
end
