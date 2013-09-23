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
end
