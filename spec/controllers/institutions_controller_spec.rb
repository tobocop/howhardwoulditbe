require 'spec_helper'

describe InstitutionsController do
  before do
    set_current_user(id: 1)
    set_virtual_currency
  end

  describe 'GET search' do
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
      Plink::InstitutionRecord.stub(:where).and_return([double(intuit_institution_id: 4)])
      controller.stub(:user_logged_in?).and_return(true)
      institution_data = {
        result: {
          institution_detail: {
            email_address: 'cooldude@aol.com',
            home_url: 'stuff.com',
            phone_number: '303-867-5309',
            keys: { key: {}}
          }
        }
      }
      Aggcat.stub_chain([:scope, :institution]).and_return(institution_data)
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

      it 'calls intuit' do
        Plink::InstitutionRecord.stub(:where).and_return([double(intuit_institution_id: 22501)])

        IntuitInstitutionRequest.should_receive(:institution_data).with(1, 22501).and_return(intuit_response)

        get :authentication, id: 1
      end

      it 'returns an institution form presenter' do
        controller.stub(:intuit_institution_data).and_return(intuit_response)

        get :authentication, id: 1

        assigns(:institution_form).should be_a InstitutionFormPresenter
      end
    end
  end

  describe 'POST authenticate' do
    let(:record_class) { Plink::IntuitAccountRequestRecord }

    before do
      set_current_user(id: 1)
      set_virtual_currency
      controller.stub(:intuit_accounts)
      session[:intuit_institution_id] = 14
    end

    it 'deletes all previous request objects for the current_user' do
      previous_requests = double(delete_all: true)

      record_class.should_receive(:where).with(user_id: 1).and_return(previous_requests)
      previous_requests.should_receive(:delete_all)

      post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
    end

    it 'creates a request object' do
      Plink::IntuitAccountRequestRecord.should_receive(:create!).
        with(user_id: 1, processed: false).and_return(double(id: 21))

      post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
    end

    it 'creates a delayed request to intuit' do
      controller.unstub(:intuit_accounts)
      intuit_account_request = mock(IntuitAccountRequest)

      IntuitAccountRequest.should_receive(:new).with(1, anything, 14, anything).and_return(intuit_account_request)

      intuit_account_request.should_receive(:delay).and_return(double(accounts: true))

      post :authenticate, field_labels: ['field_one', 'field_two'], field_one: 'user', field_two: 'password'
    end
  end

  describe 'GET poll' do
    before do
      institution = double(intuit_institution_id: 1)
      Plink::InstitutionRecord.stub_chain(:where, :first).and_return(institution)
      controller.stub(:institution_form).and_return(true)
    end

    it "finds the user's intuit account request record" do
      Plink::IntuitAccountRequestRecord.should_receive(:where).with(user_id: 1, processed: true).and_call_original

      get :poll
    end

    it 'decrypts the stored response' do
      response = {error: false, value:[{account_id: 1}]}.to_json
      request = double(response: response, destroy: true)
      Plink::IntuitAccountRequestRecord.stub_chain(:where, :first).and_return(request)

      ENCRYPTION.should_receive(:decrypt_and_verify).with(response).and_return(response)

      get :poll
    end

    it 'return an unprocessible entity when the request has not been completed yet' do
      Plink::IntuitAccountRequestRecord.stub_chain(:where, :first).and_return([])

      get :poll

      response.status.should == 422
    end

    context 'error handling' do
      before do
        request = double(present?: true, response: '', destroy: true)
        Plink::IntuitAccountRequestRecord.stub_chain(:where, :first).and_return(request)
      end

      it 'without an error renders the account list' do
        ENCRYPTION.stub(:decrypt_and_verify).and_return({'error' => false}.to_json)

        get :poll

        response.should render_template partial: 'institutions/_select_account'
      end

      it 'with an error renders the authentication form' do
        Plink::InstitutionRecord.stub_chain(:where).and_return([double(intuit_institution_id: 10000)])
        controller.stub(:institution_form)
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
        Plink::IntuitAccountRequestRecord.stub_chain(:where, :first).and_return(request)

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
      records = Array(mock(Plink::IntuitAccountRequestRecord))
      Plink::IntuitAccountRequestRecord.stub(:where).and_return(records)

      records.should_receive(:delete_all)

      post :text_based_mfa, institution_id: 1
    end

    it 'creates a new intuit account request record' do
      Plink::IntuitAccountRequestRecord.should_receive(:create!).
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
    it 'renders the congratulations view' do
      post :select

      response.should render_template 'congratulations'
    end
  end
end
