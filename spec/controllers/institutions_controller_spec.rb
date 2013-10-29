require 'spec_helper'

describe InstitutionsController do
  before { controller.stub(:user_logged_in?).and_return(true) }

  describe 'GET search' do
    it 'is successful' do
      get :search

      response.should be_success
    end

    it 'requires the user to be logged in' do
      controller.unstub(:user_logged_in?)
      controller.stub(:user_logged_in?).and_return(false)

      get :search

      response.should redirect_to root_path
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
      Plink::InstitutionRecord.should_receive(:search).with("AK's bank")

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

    it 'requires the user to be logged in' do
      controller.unstub(:user_logged_in?)
      controller.stub(:user_logged_in?).and_return(false)

      get :search

      response.should redirect_to root_path
    end
  end

  describe 'GET authorization_form' do
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
      get :authorization_form, id: 1

      response.should be_success
    end

    it 'renders the authorization_form' do
      get :authorization_form, id: 1

      response.should render_template 'authorization_form'
    end

    it 'redirects the user if given an invalid institution id' do
      Plink::InstitutionRecord.unstub(:where)
      Plink::InstitutionRecord.should_receive(:where).with(institutionID: 1.to_s).and_return([])

      get :authorization_form, id: 1

      response.should redirect_to institution_search_path
      flash[:error].should == 'Invalid institution provided. Please try again.'
    end

    context 'retrieving data from intuit' do
      let(:intuit_response) do
        {
          :status_code=>"200",
          :result=>
            {:institution_detail=>
              {:institution_id=>"22501",
               :institution_name=>"New Castle Bellco FCU - Investments",
               :home_url=>"http://www.newcastlebellco.com/",
               :address=>nil,
               :special_text=>
                "Please enter your New Castle Bellco FCU - Investments Financial Organization Number, User ID and Password required for login.",
               :currency_code=>"USD",
               :keys=>
                {:key=>
                  [{:name=>"CustId",
                    :status=>"Active",
                    :display_flag=>"true",
                    :display_order=>"2",
                    :mask=>"false",
                    :description=>"User ID"},
                   {:name=>"Passwd",
                    :status=>"Active",
                    :display_flag=>"true",
                    :display_order=>"3",
                    :mask=>"true",
                    :description=>"Password"},
                   {:name=>"CorrespondentNum",
                    :status=>"Active",
                    :value_length_max=>"3",
                    :display_flag=>"true",
                    :display_order=>"1",
                    :mask=>"false",
                    :description=>"Financial Organization Number"
                  }]
                }
              }
            }
        }
      end

      before { Aggcat.stub_chain([:scope, :institution]).and_return(intuit_response) }

      it 'calls aggcat' do
        set_current_user(id: 1)
        set_virtual_currency
        Plink::InstitutionRecord.stub(:where).and_return([double(intuit_institution_id: 22501)])

        aggcat = mock(Aggcat)
        Aggcat.should_receive(:scope).with(1).and_return(aggcat)
        aggcat.should_receive(:institution).with(22501).and_return(intuit_response)

        get :authorization_form, id: 1
      end

      it 'returns an institution form presenter' do
        get :authorization_form, id: 1

        assigns(:institution_form).should be_a InstitutionFormPresenter
      end
    end
  end
end
