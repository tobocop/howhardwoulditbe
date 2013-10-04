require 'spec_helper'

describe PlinkAdmin::ContestWinningService do
  let(:contest_winning_service) { PlinkAdmin::ContestWinningService }
  let(:contest) { create_contest }

  describe '.total_non_plink_entries_for_contest' do
    it 'does not return entries from users with a plink.com email' do
      user = create_user(email: 'plinky@plink.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)

      contest_winning_service.total_non_plink_entries_for_contest(contest.id).should == 0
    end

    it 'does not return users whose email is on the contest email blacklist' do
      user = create_user(email: 'special@unique.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)
      create_contest_blacklisted_email(email_pattern: 'special@unique.com')

      contest_winning_service.total_non_plink_entries_for_contest(contest.id).should == 0
    end

    it 'excludes users by a wild-card on the sending domain' do
      user = create_user(email: 'special@unique.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)
      create_contest_blacklisted_email(email_pattern: '%unique.com')

      contest_winning_service.total_non_plink_entries_for_contest(contest.id).should == 0
    end

    it 'returns the sum of computed_entries for all users without a plink.com email' do
      user = create_user(email: 'plinky@example.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)

      contest_winning_service.total_non_plink_entries_for_contest(contest.id).should == 10
    end
  end

  describe '.cumulative_non_plink_entries_by_user' do
    it 'excludes users with a plink.com email address' do
      plink_user = create_user(email: 'plink@plink.com')

      contest_winning_service.cumulative_non_plink_entries_by_user(contest.id).should be_empty
    end

    it 'excludes users whose email is on the contest email blacklist' do
      user = create_user(email: 'special@unique.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)
      create_contest_blacklisted_email(email_pattern: 'special@unique.com')

      contest_winning_service.cumulative_non_plink_entries_by_user(contest.id).should be_empty
    end

    it 'excludes users by a wild-card on the sending domain' do
      user = create_user(email: 'special@unique.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)
      create_contest_blacklisted_email(email_pattern: '%unique.com')

      contest_winning_service.cumulative_non_plink_entries_by_user(contest.id).should be_empty
    end

    it 'returns a list of users and their entries as well as cumulative entries' do
      user_1 = create_user
      create_entry(contest_id: contest.id, user_id: user_1.id, provider: 'admin', computed_entries: 3)
      user_2 = create_user(email: 'test_2@example.com')
      create_entry(contest_id: contest.id, user_id: user_2.id, provider: 'admin', computed_entries: 13)

      cumulative_by_user = contest_winning_service.cumulative_non_plink_entries_by_user(contest.id)
      cumulative_by_user.first.user_id.should == user_1.id
      cumulative_by_user.first.entries.should == 3
      cumulative_by_user.first.cumulative_entries.should == 3

      cumulative_by_user.last.user_id.should == user_2.id
      cumulative_by_user.last.entries.should == 13
      cumulative_by_user.last.cumulative_entries.should == 16
    end
  end

  describe '.generate_outcome_table' do
    it 'raises an exception if the parameter is blank' do
      expect {
        contest_winning_service.generate_outcome_table([])
      }.to raise_error ArgumentError
    end

    it 'creates a hash with the key as the id' do
      cumulative_entries_by_user = [
        double({"user_id"=>1, "entries"=>7, "cumulative_entries"=>7}),
        double({"user_id"=>2, "entries"=>8, "cumulative_entries"=>15}),
        double({"user_id"=>3, "entries"=>3, "cumulative_entries"=>18})
      ]

      outcome_table = contest_winning_service.generate_outcome_table(cumulative_entries_by_user)
      outcome_table.should == {
        1 => 1,   2 => 1,   3 => 1,  4 => 1,  5 => 1,   6 => 1,
        7 => 1,   8 => 2,   9 => 2, 10 => 2, 11 => 2,  12 => 2,
        13 => 2, 14 => 2,  15 => 2, 16 => 3, 17 => 3,  18 => 3
      }
    end
  end

  describe '.choose_winners' do
    let(:outcome_table) {
      result = []
      600.times do |i|
        result[i+1] = i + 1
      end

      result
    }

    it 'produces 300, unique winning ids' do
      winners = contest_winning_service.choose_winners(600, outcome_table)

      winners.uniq.length.should == 300
    end
  end

  describe '.create_prize_winners!' do
    it 'raises an exception if no contest_id is given' do
      expect {
        contest_winning_service.create_prize_winners!(nil, [1,2])
      }.to raise_error ArgumentError
    end

    it 'raises an argument error if there are not exactly 150 entries given' do
      expect {
        contest_winning_service.create_prize_winners!(1, [1,2])
      }.to raise_error ArgumentError
    end

    it 'creates 150 contest_winner_records with a prize_level_id' do
      ids = []; 150.times {|i| ids << i+1 }
      create_contest_prize_level(award_count: 150)
      contest_winning_service.create_prize_winners!(1, ids)

      Plink::ContestWinnerRecord.where('prize_level_id IS NOT NULL').count.should == 150
    end
  end

  describe '.create_alternates!' do
    it 'raises an exception if no contest_id is given' do
      expect {
        contest_winning_service.create_alternates!(nil, [1,2])
      }.to raise_error ArgumentError
    end

    it 'raises an argument error if there are not exactly 150 entries given' do
      expect {
        contest_winning_service.create_alternates!(1, [1,2])
      }.to raise_error ArgumentError
    end

    it 'creates 150 contest_winner_records without a prize_level_id' do
      ids = []; 150.times {|i| ids << i+1 }
      contest_winning_service.create_alternates!(1, ids)

      Plink::ContestWinnerRecord.where(prize_level_id: nil).count.should == 150
    end
  end

  describe '.remove_winning_record_and_update_prizes' do
    let(:first_prize_level) { create_contest_prize_level(award_count: 1, contest_id: 1) }
    let(:second_prize_level) { create_contest_prize_level(award_count: 2, contest_id: 1) }
    let!(:contest_winner) {
      create_contest_winner(user_id: 1, contest_id: 1, prize_level_id: first_prize_level.id)
    }
    let!(:second_prize_winner) {
      create_contest_winner(user_id: 2, contest_id: 1, prize_level_id: second_prize_level.id)
    }
    let!(:second_second_prize_winner) {
      create_contest_winner(user_id: 3, contest_id: 1, prize_level_id: second_prize_level.id)
    }
    let!(:alternate) {
      create_contest_winner(user_id: 4, contest_id: 1, prize_level_id: nil)
    }

    it 'raises an ArgumentError if no contest_id is provided' do
      expect {
        contest_winning_service.remove_winning_record_and_update_prizes(nil, 1, 13)
      }.to raise_error ArgumentError
    end

    it 'raises an ArgumentError if no contest_winner_record_id is given' do
      expect {
        contest_winning_service.remove_winning_record_and_update_prizes(1, nil, 13)
      }.to raise_error ArgumentError
    end

    it 'removes the given winner' do
      contest_winning_service.remove_winning_record_and_update_prizes(1, contest_winner.id, 1)

      contest_winner.reload.prize_level_id.should be_nil
    end

    it 'increments all other winners in the list\'s prizes according to the prize distribution' do
      contest_winning_service.remove_winning_record_and_update_prizes(1, contest_winner.id, 1)

      second_prize_winner.reload.prize_level_id.should == first_prize_level.id
      second_second_prize_winner.reload.prize_level_id.should == second_prize_level.id
    end

    it 'moves a non-prize winning, alternate to the prize winners list' do
      contest_winning_service.remove_winning_record_and_update_prizes(1, contest_winner.id, 1)

      alternate.reload.prize_level_id.should == second_prize_level.id
    end
  end

  describe '.finalize_results!' do
    let(:winning_user_ids) { Array(1..150) }
    let!(:winner_records) do
      winning_user_ids.map do |user_id|
        create_contest_winner(contest_id: 1, user_id: user_id, prize_level_id: 1)
      end
    end

    before {
      Plink::ContestRecord.stub(:find).and_return(double(update_attributes: true))
    }

    it 'raises an exception if there are less than 150 winners' do
      expect {
        contest_winning_service.finalize_results!(1, [], 1)
      }.to raise_error ArgumentError
    end

    it 'does not effect users who were rejected' do
      two_days_ago = 2.days.ago
      rejected = create_contest_winner(user_id: 1, rejected: true, finalized_at: two_days_ago)

      contest_winning_service.finalize_results!(1, Array(2..151), 1)

      rejected.reload.finalized_at.to_i.should == two_days_ago.to_i
    end

    it 'set the finalized time, winner, rejected, and admin_user_id attribute for the winner ' do
      contest_winning_service.finalize_results!(1, winning_user_ids, 1)

      winner_records.each do |winner_record|
        winner_record.reload.finalized_at.should_not be_nil
        winner_record.reload.winner.should be_true
        winner_record.reload.rejected.should be_false
        winner_record.admin_user_id.should_not be_nil
      end
    end

    it 'sets the rejected attribute for alternates without prizes' do
      alternate_user_ids = Array(151..243)
      alternates = alternate_user_ids.map do |user_id|
        create_contest_winner(contest_id: 1, user_id: user_id, prize_level_id: nil)
      end

      contest_winning_service.finalize_results!(1, winning_user_ids, 1)

      alternates.each do |alternate|
        alternate.reload.finalized_at.should_not be_nil
        alternate.reload.winner.should be_false
        alternate.reload.rejected.should be_true
        alternate.admin_user_id.should_not be_nil
      end
    end

    it 'sets the finalized attribute on the contest' do
      Plink::ContestRecord.unstub(:find)

      contest = create_contest
      contest_winning_service.finalize_results!(contest.id, winning_user_ids, 1)

      contest.reload.finalized_at.to_date.should == Time.zone.today
    end
  end

  describe '.notify_winners!' do
    let(:contest_id) { 1 }
    let(:user) { create_user }
    let(:prize_level_id) { 3 }

    it 'should send an email to all contest prize winners' do
      # Stub in class from parent Application
      class ContestMailer
      end
      ContestMailer.should_receive(:winner_email).exactly(1).times.and_return(double(deliver: true))

      winner = create_contest_winner({
        user_id: user.id,
        contest_id: contest_id,
        prize_level_id: prize_level_id,
        winner: true,
        rejected: false,
        finalized_at: Time.zone.now
      })

      contest_winning_service.notify_winners!(contest_id)
    end

    it 'should not email contest alternates' do
      winner = create_contest_winner({
        user_id: user.id,
        contest_id: contest_id,
        prize_level_id: nil,
        winner: false,
        rejected: true,
        finalized_at: Time.zone.now
      })

      contest_winning_service.notify_winners!(contest_id)

      ActionMailer::Base.deliveries.should be_empty
    end
  end
end
