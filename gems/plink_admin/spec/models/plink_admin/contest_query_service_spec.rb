require 'spec_helper'

describe PlinkAdmin::ContestQueryService do
  let(:contest_query_service) { PlinkAdmin::ContestQueryService }
  let!(:user) { create_user }
  let(:contest_id) { 1 }
  let(:prize_level_id) { 1 }

  describe '.get_statistics' do
    subject(:contest_query_service) { PlinkAdmin::ContestQueryService }

    it 'makes calls to the data warehouse' do
      PlinkAdmin::Warehouse.connection.should_receive(:select_all).twice.and_return([])

      contest_query_service.get_statistics(1)
    end
  end

  describe '.winning_users_grouped_by_prize_level' do
    it 'returns users who have a contest_winners entry with a non-null prize_level_id' do
      create_entry(user_id: user.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user.id, contest_id: contest_id, prize_level_id: prize_level_id)

      winning_users = contest_query_service.winning_users_grouped_by_prize_level(contest_id)

      winning_users[prize_level_id].map(&:user_id).should include user.id
    end
    it 'returns users who have a contest_winners entry with a null prize_level_id' do
      create_entry(user_id: user.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user.id, contest_id: contest_id, prize_level_id: nil)

      winning_users = contest_query_service.winning_users_grouped_by_prize_level(contest_id)

      winning_users[prize_level_id].should be_nil
    end
    it 'does not return users who do not have a contest_winners entry' do
      winning_users = contest_query_service.winning_users_grouped_by_prize_level(contest_id)

      winning_users[prize_level_id].should be_nil
    end
  end

  describe '.alternates' do
    it 'returns users who have a contest_winners entry with a null prize_level_id' do
      create_entry(user_id: user.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user.id, contest_id: contest_id, prize_level_id: nil)

      alternates = contest_query_service.alternates(contest_id)

      alternates.map(&:user_id).should include user.id
    end
    it 'does not return users who have a contest_winners entry with a non-null prize_level_id' do
      create_entry(user_id: user.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user.id, contest_id: contest_id, prize_level_id: prize_level_id)

      alternates = contest_query_service.alternates(contest_id)

      alternates.should be_empty
    end
    it 'does not return users who do not have a contest_winners entry' do
      alternates = contest_query_service.alternates(contest_id)

      alternates.should be_empty
    end
  end

  describe '.rejected' do
    it 'returns users who have a contest_winners entry with the rejected flag as true' do
      create_entry(user_id: user.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user.id, contest_id: contest_id, rejected: true)

      rejected = contest_query_service.rejected(contest_id)

      rejected.map(&:user_id).should include user.id
    end
    it 'does not return users who do have a contest_winners entry with the rejected flag set to false' do
      create_entry(user_id: user.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user.id, contest_id: contest_id, prize_level_id: nil, rejected: false)

      rejected = contest_query_service.rejected(contest_id)

      rejected.should be_empty
    end
    it 'does not return users who do not have a contest_winners entry' do
      rejected = contest_query_service.rejected(contest_id)

      rejected.should be_empty
    end
  end
end
