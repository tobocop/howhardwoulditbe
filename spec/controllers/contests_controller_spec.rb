require 'spec_helper'

describe ContestsController do
  describe 'GET index' do
    let!(:contest) { create_contest }

    it 'responds with a contest' do
      get :index

      assigns(:contest).should be_present
    end

    it 'responds with a user' do
      get :index

      assigns(:user).should be_present
    end

    context 'with an unauthenticated user' do
      before do
        session[:tracking_params] = {sub_id_three: contest.id}
        get :index
      end

      it 'responds sucessfully' do
        response.should be_success
      end


      it 'responds with 0 points' do
        assigns(:entries)[:total].should == 0
      end

      it 'responds with false user_has_linked_card' do
        assigns(:user_has_linked_card).should be_false
      end

      it 'generates a card_link_url' do
        assigns(:card_link_url).should == 'http://www.plink.dev/index.cfm?fuseaction=intuit.selectInstitution&subID2=contest_id_' + contest.id.to_s
      end

      it 'sets the tracking_params sub_id_two in the session to the contest id' do
        session[:tracking_params][:sub_id_two].should == "contest_id_#{contest.id}"
      end

      it 'maintains current tracking_params when setting the new param' do
        session[:tracking_params][:sub_id_three].should == contest.id
      end
    end

    context 'with a logged in user' do
      let(:user) { create_user }

      before do
        create_virtual_currency
        session[:current_user_id] = user.id
      end

      it 'does not set a return_to_path' do
        get :index
        controller.get_return_to_path.should be_nil
      end

      it 'sets the share state on the entries variable' do
        EntriesPresenter.any_instance.stub(:share_state).and_return{ 'share_state' }

        get :index

        assigns(:entries)[:share_state].should == 'share_state'
      end

      it 'responds with the current user\'s total contest entries' do
        Plink::ContestEntryService.should_receive(:total_entries)
          .with(contest.id, user.id).and_return(13)

        get :index

        assigns(:entries)[:total].should == 13
      end

      it 'responds with the number of entries the user will get if they share' do
        Plink::ContestEntryService.should_receive(:total_entries_via_share)
          .with(user.id, contest.id, false, anything).and_return(2300)

        get :index

        assigns(:entries)[:shared].should == 2300
      end

      context 'that has a linked card' do
        before do
          create_oauth_token(user_id: user.id)
          create_users_institution_account(user_id: user.id)
          session[:current_user_id] = user.id
        end

        it 'responds with true user_has_linked_card' do
          get :index

          assigns(:user_has_linked_card).should be_true
        end
      end

      context 'that just linked their card' do
        it 'sets a flash notice to tell the user about the bonus' do
          get :index, {card_linked: true}
          flash[:notice].should == "Congratulations! You'll now earn 5X the entries. Don't forget to add your favorite stores and restaurants to your Wallet and earn rewards for all your purchases."
        end
      end
    end
  end

  describe 'GET show' do
    let!(:unexpected_contest) { create_contest }
    let!(:contest) { create_contest }

    it 'responds with a contest' do
      get :show, id: contest.id

      assigns(:contest).should be_present
    end

    it 'responds with a user' do
      get :show, id: contest.id

      assigns(:user).should be_present
    end

    context 'with an unauthenticated user' do
      before { get :show, {id: contest.id} }

      it 'responds sucessfully' do
        response.should be_success
      end

      it 'responds with the correct contest based on the url' do
        assigns(:contest).should be_present
        assigns(:contest).id.should == contest.id
      end

      it 'responds with 0 points' do
        assigns(:entries)[:total].should == 0
      end

      it 'responds with false user_has_linked_card' do
        assigns(:user_has_linked_card).should be_false
      end

      it 'generates a card_link_url' do
        assigns(:card_link_url).should == 'http://www.plink.dev/index.cfm?fuseaction=intuit.selectInstitution&subID2=contest_id_' + contest.id.to_s
      end
    end

    context 'with a logged in user' do
      let(:user) { create_user }

      before do
        create_virtual_currency
        session[:current_user_id] = user.id
      end

      it 'does not set a return_to_path' do
        get :show, {id: contest.id}
        controller.get_return_to_path.should be_nil
      end

      it 'sets the share state on the entries variable' do
        EntriesPresenter.any_instance.stub(:share_state).and_return{ 'share_state' }

        get :show, {id: contest.id}

        assigns(:entries)[:share_state].should == 'share_state'
      end

      it 'responds with the current user\'s total contest entries' do
        Plink::ContestEntryService.should_receive(:total_entries)
          .with(contest.id, user.id).and_return(13)

        get :show, {id: contest.id}

        assigns(:entries)[:total].should == 13
      end

      it 'responds with the number of entries the user will get if they share' do
        Plink::ContestEntryService.should_receive(:total_entries_via_share)
          .with(user.id, contest.id, false, anything).and_return(2300)

        get :show, {id: contest.id}

        assigns(:entries)[:shared].should == 2300
      end

      context 'that has a linked card' do
        before do
          create_oauth_token(user_id: user.id)
          create_users_institution_account(user_id: user.id)
          session[:current_user_id] = user.id
        end

        it 'responds with true user_has_linked_card' do
          get :show, {id: contest.id}

          assigns(:user_has_linked_card).should be_true
        end
      end

      context 'that just linked their card' do
        it 'sets a flash notice to tell the user about the bonus' do
          get :show, {card_linked: true, id: contest.id}
          flash[:notice].should == "Congratulations! You'll now earn 5X the entries. Don't forget to add your favorite stores and restaurants to your Wallet and earn rewards for all your purchases."
        end
      end
    end
  end

  describe 'POST toggle_opt_in_to_daily_reminder' do
    let(:user) { create_user }
    let(:contest) {create_contest }

    before do
      create_virtual_currency
      session[:current_user_id] = user.id
    end

    it 'responds successfully when user record is successfully updated' do
      post :toggle_opt_in_to_daily_reminder, daily_contest_reminder: 'true', contest_id: contest.id

      response.should be_success
    end

    it 'responds with an unprocessable entity when the user record cannot be updated' do
      Plink::UserRecord.any_instance.stub(:opt_in_to_daily_contest_reminders!).and_return(false)

      post :toggle_opt_in_to_daily_reminder, daily_contest_reminder: 'false', contest_id: contest.id

      response.status.should == 422
    end
  end
end