require 'spec_helper'

describe PlinkAdmin::SharePagesController do
  let(:admin) { create_admin }
  let!(:share_page) { create_share_page}

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all share_pages in the database' do
      assigns(:share_pages).should == [share_page]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new share_page' do
      assigns(:share_page).should be_present
      assigns(:share_page).should_not be_persisted
    end
  end

  describe 'POST create' do
    it 'creates a share_page record and redirects to the listing when successful' do
      share_page_params = {
        name: 'Here we go',
        partial_path: 'my_page.html.haml'
      }

      post :create, {share_page: share_page_params}
      share_page = Plink::SharePageRecord.last
      share_page.name.should == 'Here we go'
      share_page.partial_path.should == 'my_page.html.haml'
      flash[:notice].should == 'Share page created successfully'

      response.should redirect_to '/share_pages'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::SharePageRecord.should_receive(:create).with({ 'name' => 'created name', 'partial_path' => 'path.html.haml' }).and_return(double(persisted?: false))

      post :create, {share_page: {name: 'created name', partial_path: 'path.html.haml'}}

      flash[:notice].should == 'Share page could not be created'
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: share_page.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the share_page by id' do
      assigns(:share_page).should == share_page
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: share_page.id, share_page: {name: 'updated name'}}
      share_page.reload.name.should == 'updated name'
      flash[:notice].should == 'Share page updated'
      response.should redirect_to '/share_pages'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::SharePageRecord.should_receive(:find).with(share_page.id.to_s).and_return(share_page)
      share_page.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: share_page.id, share_page: {name: 'updated name'}}

      flash[:notice].should == 'Share page could not be updated'
      response.should render_template 'edit'
    end
  end
end
