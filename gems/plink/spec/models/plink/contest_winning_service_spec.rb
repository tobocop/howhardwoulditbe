require 'spec_helper'

describe Plink::ContestWinningService do
  let(:contest) { create_contest }

  describe '.total_non_plink_entries_for_contest' do
    it 'does not return entries from users with a plink.com email' do
      user = create_user(email: 'plinky@plink.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)

      Plink::ContestWinningService.total_non_plink_entries_for_contest(contest.id)
    end

    it 'returns the sum of computed_entries for all users without a plink.com email' do
      user = create_user(email: 'plinky@example.com')
      create_entry(contest_id: contest.id, user_id: user.id, provider: 'admin', computed_entries: 10)

      Plink::ContestWinningService.total_non_plink_entries_for_contest(contest.id)
    end
  end

  describe '.cumulative_non_plink_entries_by_user' do
    it 'excludes users with a plink.com email address' do
      plink_user = create_user(email: 'plink@plink.com')

      Plink::ContestWinningService.cumulative_non_plink_entries_by_user(contest.id).should be_empty
    end

    it 'returns a list of users and their entries as well as cumulative entries' do
      user_1 = create_user
      create_entry(contest_id: contest.id, user_id: user_1.id, provider: 'admin', computed_entries: 3)
      user_2 = create_user(email: 'test_2@example.com')
      create_entry(contest_id: contest.id, user_id: user_2.id, provider: 'admin', computed_entries: 13)

      cumulative_by_user = Plink::ContestWinningService.cumulative_non_plink_entries_by_user(contest.id)
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
        Plink::ContestWinningService.generate_outcome_table([])
      }.to raise_error ArgumentError
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
      winners = Plink::ContestWinningService.choose_winners(600, outcome_table)

      winners.uniq.length.should == 300
    end
  end

  describe '.create_prize_winners!' do
    it 'raises an exception if no contest_id is given' do
      expect {
        Plink::ContestWinningService.create_prize_winners!(nil, [1,2])
      }.to raise_error ArgumentError
    end

    it 'raises an argument error if there are not exactly 150 entries given' do
      expect {
        Plink::ContestWinningService.create_prize_winners!(1, [1,2])
      }.to raise_error ArgumentError
    end

    it 'creates 150 contest_winner_records with a prize_level_id' do
      ids = []; 150.times {|i| ids << i+1 }
      create_contest_prize_level(award_count: 150)
      Plink::ContestWinningService.create_prize_winners!(1, ids)

      Plink::ContestWinnerRecord.where('prize_level_id IS NOT NULL').count.should == 150
    end
  end

  describe '.create_alternates!' do
    it 'raises an exception if no contest_id is given' do
      expect {
        Plink::ContestWinningService.create_alternates!(nil, [1,2])
      }.to raise_error ArgumentError
    end

    it 'raises an argument error if there are not exactly 150 entries given' do
      expect {
        Plink::ContestWinningService.create_alternates!(1, [1,2])
      }.to raise_error ArgumentError
    end

    it 'creates 150 contest_winner_records without a prize_level_id' do
      ids = []; 150.times {|i| ids << i+1 }
      Plink::ContestWinningService.create_alternates!(1, ids)

      Plink::ContestWinnerRecord.where(prize_level_id: nil).count.should == 150
    end
  end
end
