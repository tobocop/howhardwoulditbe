require 'spec_helper'

describe EntriesController do
  render_views

  describe 'POST create' do
    let(:user) { create_user }
    let(:contest) { create_contest(non_linked_image: 'image.png') }

    context 'for an authenticated user' do
      before do
        create_virtual_currency
        session[:current_user_id] = user.id
      end

      context 'with a successful request for a single provider' do
        before do
          session[:contest_source] = 'my_source'
          post :create, contest_id: contest.id, providers: "twitter"
        end

        it 'responds with a success status code (200)' do
          response.status.should == 200
        end

        it 'creates an entry record with the contest id and user id' do
          entry = Plink::EntryRecord.last
          entry.contest_id.should == contest.id
          entry.user_id.should == user.id
          entry.provider.should == 'twitter'
          entry.source.should == 'my_source'
        end

        it 'returns a count of incremental entries' do
          JSON.parse(response.body)['incremental_entries'].should == 1
        end

        it 'returns a count of total entries' do
          JSON.parse(response.body)['total_entries'].should == 1
        end

        it 'indicates that the share button should be enabled' do
          JSON.parse(response.body)['disable_submission'].should be_false
        end

        it 'returns the button text' do
          JSON.parse(response.body)['button_text'].should be_present
        end

        it 'returns the entries subtext' do
          JSON.parse(response.body)['sub_text'].should be_present
        end

        it 'returns the set_checkbox attribute' do
          JSON.parse(response.body)['set_checkbox'].should be_present
        end

        it 'returns the providers the user has not posted on' do
          JSON.parse(response.body)['available_providers'].should == 'facebook'
        end

        it 'indicates that the non linked image should be shown if the contest has a non linked image' do
          JSON.parse(response.body)['show_non_linked_image'].should be_true
        end

        it 'indicates that the non linked image should not be shown if the contest does not have a non linked image' do
          non_linked_contest =  create_contest(non_linked_image: nil)
          post :create, contest_id: non_linked_contest.id, providers: 'facebook'
          JSON.parse(response.body)['show_non_linked_image'].should be_false
        end

        it 'indicates if the user is linked or not' do
          JSON.parse(response.body)['user_linked_card'].should be_false
        end
      end

      context 'with a successful request on facebook and twitter' do
        before do
          post :create, contest_id: contest.id, providers: "twitter,facebook"
        end

        it 'returns a count of incremental entries' do
          JSON.parse(response.body)['incremental_entries'].should == 2
        end
        it 'returns a count of total entries' do
          JSON.parse(response.body)['total_entries'].should == 2
        end

        it 'indicates that the share button should be disabled' do
          JSON.parse(response.body)['disable_submission'].should be_true
        end

        it 'returns the button text' do
          JSON.parse(response.body)['button_text'].should be_present
        end

        it 'returns the entries subtext' do
          JSON.parse(response.body)['sub_text'].should be_present
        end

        it 'returns the set_checkbox attribute' do
          JSON.parse(response.body)['set_checkbox'].should be_present
        end
      end

      context 'with an unsucessful request' do
        it 'returns an unprocessable entity status code (422)' do
          post :create, contest_id: contest.id

          response.status.should == 422
        end

        context 'when the user has exceeded their entries for a network the day' do
          before do
            create_entry(user_id: user.id, contest_id: contest.id, provider: "twitter")
            post :create, contest_id: contest.id, providers: 'twitter'
          end

          it 'returns an unprocessable entity status code (422)' do
            response.status.should == 422
          end

          it 'returns an error message' do
            JSON.parse(response.body)["errors"].should == 'Entries exceeded for Twitter'
          end
        end

        context 'when the user tries to enter on a contest that has ended' do
          before do
            ended_contest = create_contest(start_time: 5.days.ago.to_date, end_time: 2.days.ago.to_date)
            post :create, contest_id: ended_contest.id, providers: 'facebook'
          end

          it 'returns an unprocessable entity status code (422)' do
            response.status.should == 422
          end

          it 'returns an error message' do
            JSON.parse(response.body)["errors"].should == 'This contest has already ended'
          end
        end

        context 'when the user tries to enter on a contest that has not started ' do
          before do
            future_contest = create_contest(start_time: 5.days.from_now.to_date, end_time: 10.days.from_now.to_date)
            post :create, contest_id: future_contest.id, providers: 'facebook'
          end

          it 'returns an unprocessable entity status code (422)' do
            response.status.should == 422
          end

          it 'returns an error message' do
            JSON.parse(response.body)["errors"].should == 'This contest has not started yet'
          end
        end
      end

      context 'with a linked card' do
        before do
          create_oauth_token(user_id: user.id)
          create_users_institution_account(user_id: user.id)

          post :create, contest_id: contest.id, providers: 'twitter'
        end

        it 'responds with a success status code (200)' do
          response.status.should == 200
        end

        it 'creates an entry record with the multiplier and total number of entries' do
          entry = Plink::EntryRecord.last
          entry.multiplier.should == 5
          entry.computed_entries.should == 5
        end

        it 'returns a count of incremental entries' do
          JSON.parse(response.body)['incremental_entries'].should == 5
        end

        it 'returns a count of total entries' do
          JSON.parse(response.body)['total_entries'].should == 5
        end

        it 'indicates that the non linked image should not be shown' do
          JSON.parse(response.body)['show_non_linked_image'].should be_false
        end
      end

      context 'for daily contest reminder emails' do
        it 'opts the user if it is their first contest entry' do
          post :create, contest_id: contest.id, providers: 'twitter'

          user.reload.daily_contest_reminder.should be_true
        end

        it 'does not opt-in a user if already have a preference selected' do
          user.update_attribute(:daily_contest_reminder, false)

          post :create, contest_id: contest.id, providers: 'twitter'

          user.reload.daily_contest_reminder.should be_false
        end
      end
    end

    context 'for an unauthenticated user' do
      before { post :create, contest_id: contest.id }

      it 'redirects to the root path' do
        response.should redirect_to root_path
      end
    end
  end
end
