require 'spec_helper'

describe PlinkAdmin::ContestWinningQueryService do
  let(:contest_query_service) { PlinkAdmin::ContestWinningQueryService }
  let!(:user) { create_user }
  let(:contest_id) { 1 }
  let(:prize_level_id) { 1 }

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

    # This holds true for .alternates and .rejected as well
    it 'returns 1 row per winning user with the latest users institution record' do
      create_entry(user_id: user.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user.id, contest_id: contest_id, prize_level_id: prize_level_id)

      second_prize_level_id = 2
      user_2 = create_user(email: 'unique@test.com')
      create_entry(user_id: user_2.id, contest_id: contest_id, provider: 'twitter', computed_entries: 1)
      create_contest_winner(user_id: user_2.id, contest_id: contest_id, prize_level_id: second_prize_level_id)

      create_intuit_fishy_transaction(user_id: user.id, is_active: 1)
      create_intuit_fishy_transaction(user_id: user.id, is_active: 1)

      institution = create_institution(name: 'First bank of derp')
      users_institution = create_users_institution(user_id: user.id, institution_id: institution.id)

      create_oauth_token(user_id: user.id)
      create_users_institution_account(user_id: user.id, name: 'My Awesome bank account', users_institution_id: users_institution.id, account_number_last_four: 5468)

      institution_2 = create_institution(name: 'Second bank of derp')
      users_institution_2 = create_users_institution(user_id: user.id, institution_id: institution_2.id)

      create_users_institution_account(user_id: user.id, name: 'My Second Awesome bank account', users_institution_id: users_institution_2.id, account_number_last_four: 5469)

      winning_users = contest_query_service.winning_users_grouped_by_prize_level(contest_id)

      number_of_winning_users = winning_users.inject(0) {|sum, prize_level| sum += prize_level.last.length }
      number_of_winning_users.should == 2

      winning_users[prize_level_id].length.should == 1
      winning_users[prize_level_id].first['institution'].should == 'Second bank of derp'

      winning_users[second_prize_level_id].length.should == 1
      winning_users[second_prize_level_id].first['institution'].should be_blank
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
