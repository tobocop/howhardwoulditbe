require 'spec_helper'

describe InstitutionsController do
  before { ApplicationController.any_instance.stub(:user_logged_in?).and_return(true) }

  describe 'GET search' do
    it 'is successful' do
      get :search

      response.should be_success
    end

    it 'requires the user to be logged in' do
      ApplicationController.any_instance.unstub(:user_logged_in?)
      ApplicationController.any_instance.stub(:user_logged_in?).and_return(false)

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
      ApplicationController.any_instance.unstub(:user_logged_in?)
      ApplicationController.any_instance.stub(:user_logged_in?).and_return(false)

      get :search

      response.should redirect_to root_path
    end
  end
end
