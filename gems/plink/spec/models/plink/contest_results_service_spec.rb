require 'spec_helper'

describe 'Plink::ContestResultsService' do
  let(:finalized_timestamp) { 20.minutes.ago }
  let(:contest) { create_contest(end_time: 2.days.ago, finalized_at: finalized_timestamp) }
  let(:grand_prize_winner) { create_user(email: 'andy@example.com', first_name: 'Andy', last_name: 'Dufresne') }
  let(:second_prize_winner) { create_user(email: 'red@example.com', first_name: 'Ellis Boyd', last_name: 'Redding') }
  let(:another_second_prize_winner) { create_user(email: 'brooks@example.com', first_name: 'Brooks Hatlen') }
  let(:another_winner) { create_user(email: 'heywood@example.com', first_name: 'Heywood') }
  let(:alternate) { create_user(email: 'tommy@example.com', first_name: 'Tommy') }
  let(:rejected_user) { create_user(email: 'norton@example.com', first_name: 'Samuel', last_name: 'Norton') }
  let(:random_user) { create_user(email: 'byron@example.com', first_name: 'Byron Hadley') }
  let(:grand_prize) { create_contest_prize_level(contest_id: contest.id) }
  let(:second_prize) { create_contest_prize_level(contest_id: contest.id, dollar_amount: 50) }
  let(:another_prize) { create_contest_prize_level(contest_id: contest.id, dollar_amount: 2) }

  let!(:rejected_user_contest_record) {
    create_contest_winner(user_id: rejected_user.id, contest_id: contest.id, prize_level_id: nil, winner: false, rejected: true, finalized_at: finalized_timestamp)
  }

  let!(:alternate_user_contest_record) {
    create_contest_winner(user_id: alternate.id, contest_id: contest.id, prize_level_id: nil, winner: false, finalized_at: finalized_timestamp)
  }

  let!(:another_winner_contest_record) {
    create_contest_winner(user_id: another_winner.id, contest_id: contest.id, prize_level_id: another_prize.id, winner: true, finalized_at: finalized_timestamp)
  }

  let!(:another_second_prize_contest_record) {
    create_contest_winner(user_id: another_second_prize_winner.id, contest_id: contest.id, prize_level_id: second_prize.id, winner: true, finalized_at: finalized_timestamp)
  }

  let!(:second_prize_contest_record) {
    create_contest_winner(user_id: second_prize_winner.id, contest_id: contest.id, prize_level_id: second_prize.id, winner: true, finalized_at: finalized_timestamp)
  }

  let!(:grand_prize_contest_record) {
    create_contest_winner(user_id: grand_prize_winner.id, contest_id: contest.id, prize_level_id: grand_prize.id, winner: true, finalized_at: finalized_timestamp)
  }

  let(:service) { Plink::ContestResultsService.new(contest.id) }

  describe '.all_results_for_contest' do
    it 'returns a data structure of all winners/alternates/rejected by amount descending' do
      service.prepare_contest_results
      service.all_results_for_contest.should == [
        grand_prize_contest_record,
        another_second_prize_contest_record,
        second_prize_contest_record,
        another_winner_contest_record,
        alternate_user_contest_record,
        rejected_user_contest_record
      ]
    end
  end

  describe '.grand_prize_winners' do
    it 'returns an array of the grand prize winners' do
      service.prepare_contest_results
      service.grand_prize_winners.size.should == 1
    end
  end

  describe '.second_prize_winners' do
    it 'returns an array of the second prize winners' do
      service.prepare_contest_results
      service.second_prize_winners.size.should == 2
    end
  end

  describe '.grand_prize_winners_names' do
    it 'returns a comma-separated string of grand prize winner names' do
      service.prepare_contest_results
      service.grand_prize_winners_list.should == 'Andy D.'
    end
  end

  describe '.second_prize_winners_names' do
    it 'returns a comma-separated string of second prize winner names' do
      service.prepare_contest_results
      service.second_prize_winners_list.should == 'Brooks H., Ellis Boyd R.'
    end
  end

  describe '.winners' do
    it 'returns an array of arrays of the winners by dollar amount' do
      service.prepare_contest_results
      winners = service.winners
      winners.size.should == 3

      winners[0][1].size.should == 1
      winners[0][0].should == 100
      winners[1][0].should == 50
      winners[2][0].should == 2

      winners[0][1].should == [ 'Andy D.' ]

      winners[1][1].size.should == 2
      winners[1][1].should include 'Brooks H.'
      winners[1][1].should include 'Ellis Boyd R.'

      winners[2][1].size.should == 1
      winners[2][1].should == [ 'Heywood' ]
    end
  end
end