require 'spec_helper'

describe PlinkAdmin::UsersController do
  let(:admin) { create_admin }

  before do
    sign_in :admin, admin
  end

  describe 'GET search' do

    let(:mock_user_service) { mock(:user_service, search_by_email: []) }

    before do
      controller.stub(plink_user_service: mock_user_service)
    end

    it 'searches by the email param' do
      get :search, email: 'user@example.com'

      assigns(:users).should == []
    end

    it 'assigns the search term' do
      get :search, email: 'user@example.com'

      assigns(:search_term).should == 'user@example.com'
    end

    it 'renders the index view' do
      get :search, email: 'user@example.com'

      response.should render_template :index
    end
  end
end
