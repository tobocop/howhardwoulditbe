require 'spec_helper'

describe PlinkAdmin::ContestsController do
  let(:admin) { create_admin }
  let!(:contest) { create_contest(
    start_time: 2.days.ago.to_date,
    end_time: 2.days.from_now.to_date
  )}

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all contests in the database' do
      assigns(:contests).should == [contest]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new contest' do
      assigns(:contest).should be_present
      assigns(:contest).should_not be_persisted
    end
  end

  describe 'POST create' do
    it 'creates a contest record and redirects to the listing when successful' do
      contest_params = {
        description: 'Created description',
        image: '/assets/profile.jpg',
        prize: 'This is the prize - a car!',
        start_time: 10.days.ago.to_date,
        end_time: 5.days.ago.to_date,
        terms_and_conditions: 'This is a set of terms and conditions'
      }

      post :create, {contest: contest_params}
      contest = Plink::ContestRecord.last
      contest.description.should == 'Created description'
      response.should redirect_to '/contests'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::ContestRecord.should_receive(:create).with({ 'description' => 'created description' }).and_return(double(persisted?: false))

      post :create, {contest: {description: 'created description'}}

      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: contest.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the contest by id' do
      assigns(:contest).should == contest
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: contest.id, contest: {description: 'updated description'}}
      contest.reload.description.should == 'updated description'
      response.should redirect_to '/contests'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::ContestRecord.should_receive(:find).with(contest.id.to_s).and_return(contest)
      contest.should_receive(:update_attributes).with({ 'description' => 'updated description' }).and_return(false)

      put :update, {id: contest.id, contest: {description: 'updated description'}}

      response.should render_template 'edit'
    end
  end

  describe 'GET search' do
    let!(:user) { create_user(email: 'test@example.com') }

    it 'gets the first contest record' do
      get :search, email: 'something@example.com'

      assigns(:contest).should == contest
    end

    it 'returns the correct user given an email' do
      get :search, email: 'test@example.com'

      assigns(:users).map(&:user_record).should include user
    end

    it 'returns the correct user given an id' do
      get :search, user_id: user.id

      assigns(:users).map(&:user_record).should include user
    end

    it 'returns an empty array if no params are given' do
      get :search

      assigns(:users).should be_empty
    end

    it 'returns the search term' do
      get :search, email: 'mysearch@example.com'

      assigns(:search_term).should == 'mysearch@example.com'
    end
  end

  describe 'GET user_entry_stats' do
    let!(:user) { create_user}

    it 'returns the contest corresponding to the id parameter' do
      get :user_entry_stats, contest_id: contest.id

      assigns(:contest).should == contest
    end

    it 'returns the user_id' do
      get :user_entry_stats, user_id: user.id, contest_id: contest.id

      assigns(:contest).should == contest
    end

    it 'returns the multiplier' do
      Plink::ContestEntryService.stub(:user_multiplier).and_return(1)

      get :user_entry_stats, user_id: user.id, contest_id: contest.id

      assigns(:multiplier).should == 1
    end

    it 'returns all entries' do
      entry = create_entry(contest_id: contest.id, user_id: user.id)

      get :user_entry_stats, user_id: user.id, contest_id: contest.id

      assigns(:entries).should include entry
    end

    it 'raises an exception if no contest_id is given' do
      expect {
        get :user_entry_stats
      }.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe 'POST entries' do
    let(:user) { create_user }

    before { post :entries, user_id: user.id, contest_id: contest.id, number_of_entries: 123 }

    context 'with a successful request' do
      it 'creates an entry record' do
        entry_record = Plink::EntryRecord.last
        entry_record.user_id.should == user.id
        entry_record.contest_id.should == contest.id
        entry_record.provider.should == 'admin'
        entry_record.referral_entries.should == 0
        entry_record.multiplier.should == 1
        entry_record.computed_entries.should == 123
      end

      it 'renders a flash notice indicating success' do
        flash[:notice].should == 'Successfully awarded 123 entries.'
      end
    end

    context 'with a failed request' do
      it 'renders a flash notice indicating failure' do
        post :entries, contest_id: contest.id, number_of_entries: 123

        flash[:notice].should include 'Could not add entries:'
      end
    end
  end

  describe 'GET statistics' do
    let!(:contest) { create_contest }
    let!(:second_contest) { create_contest(start_time: 10.years.from_now, end_time: 11.years.from_now) }
    let(:stats_return) {
      {
        entries: [],
        emails_and_link_cards: []
      }
    }

    it 'returns all contests' do
      PlinkAdmin::ContestQueryService.stub(:get_statistics).and_return(stats_return)

      get :statistics

      assigns(:contests).should include Plink::ContestRecord.first
      assigns(:contests).should include Plink::ContestRecord.last
    end

    it 'returns statistics' do
      PlinkAdmin::ContestQueryService.stub(:get_statistics).and_return(stats_return)

      get :statistics

      assigns(:statistics).should == stats_return.stringify_keys
    end

    it 'calls the query service for data about the contest' do
      PlinkAdmin::ContestQueryService.should_receive(:get_statistics).
      with(contest.id.to_s)

      get :statistics, contest_id: contest.id
    end

    it 'changes to getting data for a different contest if a change_contest_id is given' do
      PlinkAdmin::ContestQueryService.should_receive(:get_statistics).
      with(second_contest.id.to_s)

      get :statistics, contest_id: contest.id, change_contest_id: second_contest.id

      assigns(:contest).should == second_contest
    end

    it 'defaults to using the current contest if no contest_id is given' do
      Plink::ContestRecord.should_receive(:current).and_call_original

      PlinkAdmin::ContestQueryService.should_receive(:get_statistics).
      with(contest.id).and_return(stats_return)

      get :statistics

      assigns(:contest).should == contest
    end
  end

  describe 'GET winners' do
    it 'returns an empty collection if not provided a contest_id' do
      get :winners

      assigns(:prize_levels).should be_empty
      assigns(:winners).should be_empty
      assigns(:alternates).should be_empty
      assigns(:rejected).should be_empty
    end

    it 'returns the set of prize levels for the given contest' do
      Plink::ContestPrizeLevelRecord.should_receive(:where).with(contest_id: 1.to_s).
        and_return(double)

      get :winners, contest_id: 1

      assigns(:prize_levels).should_not be_nil
    end

    it 'returns the set of prize winners for the given contest' do
      PlinkAdmin::ContestQueryService.should_receive(:winning_users_grouped_by_prize_level).
        with(1.to_s).and_return(double)

      get :winners, contest_id: 1

      assigns(:winners).should_not be_nil
    end

    it 'returns the set of alternates for the given contest' do
      PlinkAdmin::ContestQueryService.should_receive(:alternates).with(1.to_s).
        and_return(double)

      get :winners, contest_id: 1

      assigns(:alternates).should_not be_nil
    end

    it 'returns the set of rejected winners for the given contest' do
      PlinkAdmin::ContestQueryService.should_receive(:rejected).with(1.to_s).
        and_return(double)

      get :winners, contest_id: 1

      assigns(:rejected).should_not be_nil
    end
  end

  describe 'GET remove_winner' do
    let(:contest_id) { 1 }
    let(:contest_winner_id) { 3 }

    before do
      Plink::ContestWinningService.should_receive(:remove_winning_record_and_update_prizes).
        with(contest_id.to_s, contest_winner_id.to_s, anything).and_return(nil)
    end
    it 'renders the winners view' do
      get :remove_winner, contest_id: contest_id, contest_winner_id: contest_winner_id

      response.should render_template :winners
    end

    it 'calls the Contest Winning Service to remove the winner and update the others' do
      get :remove_winner, contest_id: contest_id, contest_winner_id: contest_winner_id
    end

    it 'returns the same variables as GET winners' do
      Plink::ContestPrizeLevelRecord.should_receive(:where).with(contest_id: contest_id.to_s).
        and_return(double)
      PlinkAdmin::ContestQueryService.should_receive(:winning_users_grouped_by_prize_level).
        with(contest_id.to_s).and_return(double)
      PlinkAdmin::ContestQueryService.should_receive(:alternates).with(contest_id.to_s).
        and_return(double)
      PlinkAdmin::ContestQueryService.should_receive(:rejected).with(contest_id.to_s).
        and_return(double)

      get :remove_winner, contest_id: contest_id, contest_winner_id: contest_winner_id

      assigns(:prize_levels).should_not be_nil
      assigns(:winners).should_not be_nil
      assigns(:alternates).should_not be_nil
      assigns(:rejected).should_not be_nil
    end
  end

  describe 'POST accept_winners' do
    let(:contest_id) { 1 }

    context 'with less than 150 user ids' do
      before { post :accept_winners, contest_id: contest_id, user_ids: [1,2,3] }

      it 'returns an error if there are less than 150 user ids' do
        assigns(:errors).should == { 'message' => 'Must have 150 winners.' }
      end

      it 'renders the winners template' do
        response.should render_template :winners
      end
    end

    it 'calls the Contest Winning Service to finalize the results of the contest' do
      winner_ids = Array(1..150)
      Plink::ContestWinningService.should_receive(:finalize_results!).
        with(contest_id.to_s, winner_ids.map(&:to_s), anything)

      post :accept_winners, contest_id: contest_id, user_ids: winner_ids
    end

    it 'renders the contests index with a flash message' do
      Plink::ContestWinningService.should_receive(:finalize_results!).and_return(nil)
      winner_ids = Array(1..150)

      post :accept_winners, contest_id: contest_id, user_ids: winner_ids

      response.should redirect_to '/contests'
      flash[:notice].should_not be_nil
    end
  end
end
