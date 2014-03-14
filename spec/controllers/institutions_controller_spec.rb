require 'spec_helper'

describe InstitutionsController do
  it_should_behave_like(:tracking_extensions)

  before do
    set_current_user(id: 1)
    set_virtual_currency
  end

  let(:institution_data) do
    { result: {
        institution_detail: {
          email_address: 'cooldude@aol.com',
          home_url: 'stuff.com',
          phone_number: '303-867-5309',
          keys: { key: {}}
        }
      }
    }
  end

  describe 'GET search' do
    before do
      controller.stub(:get_return_to_path).and_return('some link')
    end

    it 'is successful' do
      get :search

      response.should be_success
    end

    it 'requires the user to be logged in' do
      controller.should_receive(:require_authentication)

      get :search
    end

    it 'returns the most popular institutions' do
      Plink::InstitutionRecord.should_receive(:most_popular).and_return([double(id: 1)])

      get :search

      assigns(:most_popular).should_not be_nil
    end

    it 'deletes the intuit_institution_login_id from the session' do
      session[:intuit_institution_login_id] = 3

      get :search

      session[:intuit_institution_login_id].should be_nil
    end

    it 'deletes the reverification_id from the session' do
      session[:reverification_id] = 4

      get :search

      session[:reverification_id].should be_nil
    end

    it 'sets the return to path in the session' do
      controller.should_receive(:get_return_to_path).with().and_return('something relevant')

      get :search

      session[:return_to_path].should == 'something relevant'
    end
  end

  describe 'POST search_results' do
    it 'is successful' do
      post :search_results, institution_name: "Joe's bank"

      response.should be_success
    end

    it 'calls the institution model to find institutions' do
      Plink::InstitutionRecord.should_receive(:search).with("AK's bank").and_return([])

      post :search_results, institution_name: "AK's bank"
    end

    it 'requires a institution_name parameter' do
      post :search_results

      response.should render_template 'search_results'
      flash[:error].should == 'Please provide a bank name or URL'
    end

    it 'returns the most popular institutions' do
      Plink::InstitutionRecord.should_receive(:most_popular).and_return([double(id: 1)])

      post :search_results

      assigns(:most_popular).should_not be_nil
    end

    it 'indicates if the returned collection has unsupported banks' do
      post :search_results, institution_name: "Joe's bank"

      assigns(:has_unsupported_banks).should_not be_nil
    end

    it 'requires the user to be logged in' do
      controller.should_receive(:require_authentication)

      post :search_results
    end
  end

  describe 'GET authentication' do
    before do
      Plink::InstitutionRecord.stub(:where).and_return([double(id: 1000, intuit_institution_id: 4)])
      controller.stub(:user_logged_in?).and_return(true)
      IntuitInstitutionRequest.stub(:institution_data).and_return(institution_data)
    end

    it 'is successful' do
      get :authentication, id: 1

      response.should be_success
    end

    it 'renders the authentication view' do
      get :authentication, id: 1

      response.should render_template 'authentication'
    end

    it 'redirects the user if given an invalid institution id' do
      Plink::InstitutionRecord.unstub(:where)
      Plink::InstitutionRecord.should_receive(:where).with(institutionID: 1.to_s).and_return([])

      get :authentication, id: 1

      response.should redirect_to institution_search_path
      flash[:error].should == 'Invalid institution provided. Please try again.'
    end

    context 'retrieving data from intuit' do
      let(:intuit_response) do
        { :status_code=>"200",
          :result => {:institution_detail=>
            {:institution_id=>"22501",
             :institution_name=>"New Castle Bellco FCU - Investments",
             :home_url=>"http://www.newcastlebellco.com/",
             :address=>nil,
             :special_text=> "Please enter your New Castle Bellco FCU",
             :currency_code=>"USD",
             :keys=>
              {:key=>
                [{:name=>"Passwd",
                  :status=>"Active",
                  :display_flag=>"true",
                  :display_order=>"3",
                  :mask=>"true",
                  :description=>"Password"
                }]
              }
            }
          }
        }
      end

      let(:institution_records) { [double(id: 4, intuit_institution_id: 22501)] }

      it 'calls intuit' do
        Plink::InstitutionRecord.stub(:where).and_return(institution_records)

        IntuitInstitutionRequest.should_receive(:institution_data).with(1, 22501).and_return(intuit_response)

        get :authentication, id: 1
      end

      it 'returns an institution form presenter' do
        controller.stub(:intuit_institution_data).and_return(intuit_response)

        get :authentication, id: 1

        assigns(:institution_form).should be_a InstitutionFormPresenter
      end

      it 'sets the institution_id in the session' do
        Plink::InstitutionRecord.stub(:where).and_return(institution_records)

        get :authentication, id: 1

        session[:institution_id].should == 4
      end

      it 'sets the intuit_institution_id in the session' do
        Plink::InstitutionRecord.stub(:where).and_return(institution_records)

        get :authentication, id: 1

        session[:intuit_institution_id].should == 22501
      end
    end
  end

  describe 'POST authenticate' do
    let(:record_class) { Plink::IntuitRequestRecord }

    before do
      set_current_user(id: 1)
      set_virtual_currency
      controller.stub(:authenticate_intuit)
      controller.stub(updating?: false)
      session[:intuit_institution_id] = 14
      session[:non_masked_fields] = ['field_one']
    end

    it 'deletes all previous request objects for the current_user' do
      previous_requests = double(delete_all: true)

      record_class.should_receive(:where).with(user_id: 1).and_return(previous_requests)
      previous_requests.should_receive(:delete_all)

      post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
    end


    it 'sets the users institution hash' do
      Digest::SHA512.should_receive(:hexdigest).with('user')

      post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
    end

    context 'when the institution has not been linked by another user' do
      it 'creates a request object' do
        Plink::IntuitRequestRecord.should_receive(:create!).
          with(user_id: 1, processed: false).and_return(double(id: 21))

        post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
      end

      it 'stores the request objects id in the session' do
        Plink::IntuitRequestRecord.stub(:create!).and_return(double(id: 492))

        post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'

        session[:intuit_account_request_id].should == 492
      end

      it 'creates a delayed account request to intuit' do
        controller.unstub(:authenticate_intuit)
        intuit_account_request = double(IntuitAccountRequest)
        delayed_intuit_account_request = double

        IntuitAccountRequest.should_receive(:new).with(1, anything, 14, anything, anything).and_return(intuit_account_request)

        intuit_account_request.should_receive(:delay).
          with(queue: 'intuit_authentication').
          and_return(delayed_intuit_account_request)
        delayed_intuit_account_request.should_receive(:authenticate).with(anything)

        post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
      end

      it 'creates a delayed update credentials request to intuit if the user is updating their account' do
        controller.unstub(:authenticate_intuit)
        controller.stub(updating?: true)
        session[:intuit_institution_login_id] = 4
        intuit_update_request = double(IntuitUpdateRequest)
        delayed_intuit_update_request = double

        IntuitUpdateRequest.should_receive(:new).with(1, anything, 14, 4).and_return(intuit_update_request)
        intuit_update_request.should_receive(:delay).
          with(queue: 'intuit_authentication').
          and_return(delayed_intuit_update_request)
        delayed_intuit_update_request.should_receive(:authenticate).with(anything)

        post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
      end
    end

    context 'when the institution has been linked by another user' do
      before do
        Plink::UsersInstitutionService.stub(:users_institution_registered?).and_return(true)
      end

      it 'returns a conflict status' do
        post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'

        response.status.should == 409
      end
    end
  end

  describe 'GET poll' do
    before do
      institution = double(intuit_institution_id: 1)
      Plink::InstitutionRecord.stub_chain(:where, :first).and_return(institution)
      controller.stub(:institution_form).and_return(true)
    end

    it "finds the user's intuit account request record" do
      Plink::IntuitRequestRecord.should_receive(:where).with(user_id: 1, processed: true).and_call_original

      get :poll
    end

    it 'decrypts the stored response' do
      response = {error: false, value:[{account_id: 1}]}.to_json
      request = double(response: response, destroy: true)
      Plink::IntuitRequestRecord.stub_chain(:where, :first).and_return(request)

      ENCRYPTION.should_receive(:decrypt_and_verify).with(response).and_return(response)

      get :poll
    end

    it 'return an unprocessible entity when the request has not been completed yet' do
      Plink::IntuitRequestRecord.stub_chain(:where, :first).and_return([])

      get :poll

      response.status.should == 422
    end

    context 'when the response has no errors' do
      before do
        request = double(present?: true, response: '', destroy: true)
        Plink::IntuitRequestRecord.stub_chain(:where, :first).and_return(request)
        ENCRYPTION.stub(:decrypt_and_verify).and_return({'error' => false}.to_json)
      end

      context 'when the user is updating' do
        before { controller.stub(:updating?).and_return(true) }

        it 'redirects to update credentials complete' do
          session[:institution_id] = 234

          get :poll

          response.should redirect_to(institution_login_credentials_updated_path(234))
        end

        context 'when the user is also reverifying' do
          before { controller.stub(:reverifying?).and_return(true) }

          it 'redirects to the reverifcation complete path' do
            get :poll

            response.should redirect_to(reverification_complete_path)
          end
        end
      end

      context 'when the user is not updating' do
        before { controller.stub(:updating?).and_return(false) }

        it 'renders the account list' do
          get :poll

          response.should render_template partial: 'institutions/_select_account'
        end
      end
    end

    context 'when the response has an error' do
      before do
        request = double(present?: true, response: '', destroy: true)
        Plink::IntuitRequestRecord.stub_chain(:where, :first).and_return(request)
      end

      it 'renders the authentication form' do
        Plink::InstitutionRecord.stub_chain(:where).and_return([double(intuit_institution_id: 10000)])
        controller.stub(:intuit_institution_data)
        controller.stub(:institution_form)
        IntuitInstitutionRequest.stub(:institution_data).and_return(institution_data)
        ENCRYPTION.stub(:decrypt_and_verify).and_return({'error' => true}.to_json)

        get :poll

        response.should render_template partial: 'institutions/authentication/_form'
      end
    end

    context 'with an MFA question' do
      let(:mfa_response) do
        {
          error: false,
          mfa: true,
          value: {
            'challenge_session_id' => '1234',
            'challenge_node_id' => '4321',
            'questions' => {text: "Who's your mamma?"}
          }
        }.to_json
      end

      before do
        request = double(present?: true, response: '', destroy: true)
        Plink::IntuitRequestRecord.stub_chain(:where, :first).and_return(request)

        ENCRYPTION.stub(:decrypt_and_verify).and_return(mfa_response)
      end

      it 'renders the text-based mfa partial' do
        get :poll

        response.should render_template partial: 'institutions/authentication/_mfa'
      end

      it 'stores the Intuit challenge tokens in the session' do
        get :poll

        session[:challenge_session_id].should == '1234'
        session[:challenge_node_id].should == '4321'
      end
    end
  end

  describe 'POST text_based_mfa' do
    before { controller.stub(:intuit_mfa).and_return(true) }

    it 'responds successfully' do
      post :text_based_mfa, institution_id: 1

      response.should be_success
    end

    it 'removes all existing account request records for the current user' do
      records = Array(double(Plink::IntuitRequestRecord))
      Plink::IntuitRequestRecord.stub(:where).and_return(records)

      records.should_receive(:delete_all)

      post :text_based_mfa, institution_id: 1
    end

    it 'creates a new intuit account request record' do
      Plink::IntuitRequestRecord.should_receive(:create!).
        with(user_id: 1, processed: false).
        and_return(double(id: 23))

      post :text_based_mfa, institution_id: 1
    end

    it 'calls to intuit with the MFA responses' do
      controller.unstub(:intuit_mfa)

      controller.should_receive(:intuit_mfa).with(['stuff', 'cool'])

      post :text_based_mfa, institution_id: 1, mfa_question_1: 'stuff', mfa_question_2: 'cool'
    end
  end

  describe 'POST select' do
    let(:users_institution_account_staging) do
      double(:users_institution_account_staging, {id: 6, users_institution_id: 1234})
    end
    let(:intuit_request_record) { double(id: 345) }
    let(:active_by_user_id) { double(pluck: [21, 56]) }

    before do
      Plink::UsersInstitutionAccountStagingRecord.stub_chain(:select, :where, :last).
        and_return(users_institution_account_staging)
      Plink::UsersInstitutionAccountRecord.stub(:active_by_user_id).and_return(active_by_user_id)
      controller.stub(:select_account)
    end

    it 'renders nothing' do
      post :select

      response.body.should be_blank
    end

    it 'returns the most recently created staged account by intuit account id' do
      select = double
      where = double

      Plink::UsersInstitutionAccountStagingRecord.should_receive(:select).
        with([:usersInstitutionAccountStagingID, :usersInstitutionID]).
        and_return(select)
      select.should_receive(:where).with(accountID: '23', userID: 1).and_return(where)
      where.should_receive(:last).and_return(users_institution_account_staging)

      post :select, intuit_account_id: 23
    end

    it 'gets a list of users institution account ids to end date' do
      Plink::UsersInstitutionAccountRecord.should_receive(:active_by_user_id).
        with(1).
        and_return(active_by_user_id)

      post :select
    end

    it 'creates a delayed job for the intuit update' do
      controller.should_receive(:select_account).with(users_institution_account_staging.id, nil, [21,56])

      post :select
    end

    it 'removes previous Plink::IntuitRequestRecords' do
      request_records = double

      Plink::IntuitRequestRecord.should_receive(:where).with(user_id: 1).
        and_return(request_records)
      request_records.should_receive(:delete_all)

      post :select
    end

    it 'creates a new Plink::IntuitRequestRecord' do
      Plink::IntuitRequestRecord.should_receive(:create!).with(user_id: 1, processed: false).
        and_return(intuit_request_record)

      post :select
    end

    it 'sets the request_id in the session' do
      Plink::IntuitRequestRecord.stub(:create!).and_return(intuit_request_record)

      post :select

      session[:intuit_account_request_id].should == 345
    end
  end

  describe 'GET select_account_poll' do
    let(:intuit_request_record) do
      double(:intuit_request_record, processed?: true, destroy: true, response: 'encrypted stuff')
    end
    let(:decrypted_failure_response) { {'error' => true} }

    before do
      Plink::IntuitRequestRecord.stub(:find).and_return(intuit_request_record)
      ENCRYPTION.stub(:decrypt_and_verify).and_return(decrypted_failure_response.to_json)
    end

    it 'responds with a 422 when the request has not been resolved' do
      Plink::IntuitRequestRecord.stub(:find).and_return(double(processed?: false))

      get :select_account_poll

      response.status.should == 422
    end

    context 'with a processed request' do
      it 'decrypts the response' do
        ENCRYPTION.should_receive(:decrypt_and_verify).with('encrypted stuff').
          and_return(decrypted_failure_response.to_json)

        get :select_account_poll
      end

      it 'parses JSON from the decrypted response' do
        JSON.should_receive(:parse).with(decrypted_failure_response.to_json).
          and_return(decrypted_failure_response)

        get :select_account_poll
      end

      context 'for a failed request' do
        it 'renders a JSON response indicating the failure' do
          get :select_account_poll

          response.body.should == {failure: true}.to_json
        end
      end

      context 'for an account request' do
        let(:decrypted_successful_response) do
          {
            'error' => false,
            'value' => {
              'updated_accounts' => 1,
              'account_name' => 'awesome'
            }
          }
        end

        before do
          ENCRYPTION.stub(:decrypt_and_verify).and_return(decrypted_successful_response.to_json)
        end

        it 'renders a JSON response indicating the success' do
          expected = {failure: false, data: {updated_accounts: 1, account_name: 'awesome'}}.to_json

          get :select_account_poll

          response.body.should == expected
        end
      end

      context 'for a transaction request' do
        let(:decrypted_successful_response) do
          {
            'error' => false,
            'value' => {'transactions' => true}
          }
        end

        before do
        end

        it 'renders success if there are transactions' do
          ENCRYPTION.stub(:decrypt_and_verify).and_return(decrypted_successful_response.to_json)

          get :select_account_poll

          response.body.should == {failure: false}.to_json
        end

        it 'renders failure if there are not transactions' do
          decrypted_successful_response['value']['transactions'] = false
          ENCRYPTION.stub(:decrypt_and_verify).and_return(decrypted_successful_response.to_json)

          get :select_account_poll

          response.body.should == {failure: true}.to_json
        end
      end
    end
  end

  describe 'GET congratulations' do
    before do
      controller.stub(:institution_authenticated).and_return('my pixel')
    end

    context 'when the user is reverifying' do
      before { controller.stub(:reverifying?).and_return(true) }

      it 'redirects to the reverifcation complete path' do
        get :congratulations

        response.should redirect_to(reverification_complete_path(full_page: true))
      end
    end

    context 'when the user is not reverifying' do
      before do
        controller.stub(:reverifying?).and_return(false)
      end

      it 'renders the congratulations view' do
        get :congratulations

        response.should render_template :congratulations
      end

      it 'returns the institution_authenticated_pixel' do
        get :congratulations

        assigns(:institution_authenticated_pixel).should == 'my pixel'
      end

      it 'returns the account_name that is given as a parameter' do
        get :congratulations, account_name: 'Rich People Account'

        assigns(:account_name).should == 'Rich People Account'
      end

      it 'checks if an institution_authenticated event should be recorded' do
        controller.should_receive(:institution_authenticated)

        get :congratulations, updated_accounts: 12234
      end

      context 'when the return to path is not nil' do
        before { session[:return_to_path] = 'a path' }

        it 'assigns a return_to_presenter to a return to presenter' do
          presenter = double(ReturnToPresenter)
          ReturnToPresenter.should_receive(:new).with('a path').and_return(presenter)

          get :congratulations, updated_accounts: 12234

          assigns(:return_to_presenter).should == presenter
        end
      end

      context 'when the return to path is nil' do
        it 'assigns a return_to_presenter to a null return to presenter' do
          presenter = double(NullReturnToPresenter)
          NullReturnToPresenter.should_receive(:new).with().and_return(presenter)

          get :congratulations, updated_accounts: 12234

          assigns(:return_to_presenter).should == presenter
        end
      end
    end
  end

  describe 'reverifying?' do
    it 'returns true if the session has a reverification_id key' do
      session[:reverification_id] = 2

      controller.reverifying?.should be_true
    end

    it 'returns false if the session does not not have a reverification_id key' do
      controller.reverifying?.should be_false
    end
  end

  describe 'updating?' do
    it 'returns true if the session has a intuit_institution_login_id key' do
      session[:intuit_institution_login_id] = 2

      controller.updating?.should be_true
    end

    it 'returns false if the session does not have a intuit_institution_login_id key' do
      controller.updating?.should be_false
    end
  end

  describe 'from_contest?' do
    it 'returns true if the session has a return_to_path key that is not nil' do
      session[:return_to_path] = 'asd'

      controller.from_contest?.should be_true
    end

    it 'returns false if the session does not not have a return_to_path key' do
      controller.from_contest?.should be_false
    end

    it 'returns false if the session has return_to_path key of nil' do
      session[:return_to_path] = nil

      controller.from_contest?.should be_false
    end
  end
end
