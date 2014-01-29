require 'spec_helper'

describe PlinkAdmin::LandingPagesController do
  let(:admin) { create_admin }
  let!(:landing_page) { create_landing_page}

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all landing_pages in the database' do
      assigns(:landing_pages).should == [landing_page]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new landing_page' do
      assigns(:landing_page).should be_present
      assigns(:landing_page).should_not be_persisted
    end
  end

  describe 'POST create' do
    it 'creates a landing_page record and redirects to the listing when successful' do
      landing_page_params = {
        cms: false,
        name: 'Here we go',
        partial_path: 'my_page.html.haml'
      }

      post :create, {landing_page: landing_page_params}
      landing_page = Plink::LandingPageRecord.last
      landing_page.name.should == 'Here we go'
      landing_page.partial_path.should == 'my_page.html.haml'
      flash[:notice].should == 'Landing page created successfully'

      response.should redirect_to '/landing_pages'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::LandingPageRecord.should_receive(:create).with({ 'name' => 'created name', 'partial_path' => 'path.html.haml' }).and_return(double(persisted?: false))

      post :create, {landing_page: {name: 'created name', partial_path: 'path.html.haml'}}

      flash[:notice].should == 'Landing page could not be created'
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: landing_page.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the landing_page by id' do
      assigns(:landing_page).should == landing_page
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: landing_page.id, landing_page: {name: 'updated name'}}
      landing_page.reload.name.should == 'updated name'
      flash[:notice].should == 'Landing page updated'
      response.should redirect_to '/landing_pages'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::LandingPageRecord.should_receive(:find).with(landing_page.id.to_s).and_return(landing_page)
      landing_page.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: landing_page.id, landing_page: {name: 'updated name'}}

      flash[:notice].should == 'Landing page could not be updated'
      response.should render_template 'edit'
    end
  end
end
