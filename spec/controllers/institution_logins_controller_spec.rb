require 'spec_helper'

describe InstitutionLoginsController do
  describe 'GET update' do
    let(:user_institution_record) { double(institution_id: 123, intuit_institution_login_id: 235) }

    before do
      Plink::UsersInstitutionRecord.stub(:find).and_return(user_institution_record)
      get :update_credentials, id: 1
    end

    it 'stores the id in the session as intuit_institution_login_id' do
      session[:intuit_institution_login_id].should == 235
    end

    it 'redirects to the user to the institutions authentication form' do
      response.should redirect_to(institution_authentication_path(123))
    end
  end

  describe 'GET credentials_updated' do
    let(:institution_record) { double(name: 'trippin') }

    before do
      Plink::InstitutionRecord.stub(:find).and_return(institution_record)
    end

    it 'renders the update complete partial' do
      get :credentials_updated, institution_id: 123

      response.should render_template partial: 'institution_logins/_credentials_updated'
    end

    it 'looks up the institution record from the institution_id in the url' do
      Plink::InstitutionRecord.should_receive(:find).with('123').and_return(institution_record)

      get :credentials_updated, institution_id: 123
    end

    it 'removes the intuit_institution_login_id from the session' do
      session[:intuit_institution_login_id] = 289374

      get :credentials_updated, institution_id: 123

      session[:intuit_institution_login_id].should be_nil
    end

    it 'assigns account_name' do
      get :credentials_updated, institution_id: 123

      assigns(:account_name).should == 'trippin'
    end
  end
end
