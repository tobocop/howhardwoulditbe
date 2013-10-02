require 'spec_helper'

describe Plink::ContestWinnerRecord do
  it { should validate_presence_of(:contest_id) }
  it { should have_db_column(:rejected).of_type(:boolean) }

  it { should validate_presence_of(:user_id) }
  it { should have_db_column(:winner).of_type(:boolean) }

  it { should allow_mass_assignment_of(:admin_user_id) }
  it { should allow_mass_assignment_of(:contest_id) }
  it { should allow_mass_assignment_of(:finalized_at) }
  it { should allow_mass_assignment_of(:prize_level_id) }
  it { should allow_mass_assignment_of(:user_id) }
end

describe 'named scopes' do
  describe '.for_contest' do
    let(:finalized_timestamp) { 1.hour.ago }
    let(:contest) { create_contest(end_time: 5.days.ago, finalized_at: finalized_timestamp) }
    let(:other_contest) { create_contest(end_time: 2.days.ago, finalized_at: finalized_timestamp) }

    let(:grand_prize_winner) { create_user(email: 'billy@example.com', first_name: 'Billy', last_name: 'Costigan') }
    let(:second_prize_winner) { create_user(email: 'queenan@example.com', first_name: 'Oliver', last_name: 'Queenan') }
    let(:another_winner) { create_user(email: 'frank@example.com', first_name: 'Frank', last_name: 'Costello') }
    let(:alternate) { create_user(email: 'dignam@example.com', first_name: 'Sean', last_name: 'Dignam' ) }
    let(:rejected_user) { create_user(email: 'ellerby@example.com', first_name: 'George', last_name: 'Ellerby') }
    let(:other_user) { create_user(email: 'colin@example.com', first_name: 'Colin', last_name: 'Sullivan') }

    let(:grand_prize) { create_contest_prize_level(contest_id: contest.id) }
    let(:second_prize) { create_contest_prize_level(contest_id: contest.id, dollar_amount: 50) }
    let(:another_prize) { create_contest_prize_level(contest_id: contest.id, dollar_amount: 2) }
    let(:other_grand_prize) { create_contest_prize_level(contest_id: other_contest.id) }

    let!(:contest_winners) do
      create_contest_winner(user_id: grand_prize_winner.id, contest_id: contest.id, prize_level_id: grand_prize.id, winner: true, finalized_at: finalized_timestamp)
      create_contest_winner(user_id: second_prize_winner.id, contest_id: contest.id, prize_level_id: second_prize.id, winner: true, finalized_at: finalized_timestamp)
      create_contest_winner(user_id: another_winner.id, contest_id: contest.id, prize_level_id: another_prize.id, winner: true, finalized_at: finalized_timestamp)
      create_contest_winner(user_id: alternate.id, contest_id: contest.id, prize_level_id: nil, winner: false, finalized_at: finalized_timestamp)
      create_contest_winner(user_id: rejected_user.id, contest_id: contest.id, prize_level_id: nil, winner: false, rejected: true, finalized_at: finalized_timestamp)
      create_contest_winner(user_id: other_user.id, contest_id: other_contest.id, prize_level_id: other_grand_prize.id, winner: true, rejected: false, finalized_at: finalized_timestamp)
    end

    it 'returns the results for a given contest' do
      results = Plink::ContestWinnerRecord.for_contest(contest.id)
      results.size.should == 5
    end

    it 'does not return results for other contests' do
      results = Plink::ContestWinnerRecord.for_contest(contest.id)
      results.pluck(:user_id).should_not include(other_user.id)
      results.pluck(:contest_id).should include(contest.id)
      results.pluck(:contest_id).should_not include(other_contest.id)
    end

  end
end
