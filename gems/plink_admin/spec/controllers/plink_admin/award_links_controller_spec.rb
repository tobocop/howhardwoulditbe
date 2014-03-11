require 'spec_helper'

describe PlinkAdmin::AwardLinksController do
  let(:admin) { create_admin }
  let!(:award_link) { create_award_link }
  let(:award_type_record) { double(Plink::AwardTypeRecord) }

  before do
    Plink::AwardTypeRecord.stub(:all).and_return([award_type_record])
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all award_links in the database' do
      assigns(:award_links).should == [award_link]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new award_link' do
      assigns(:award_link).should be_present
      assigns(:award_link).should_not be_persisted
    end

    it 'gets all award types in the database' do
      assigns(:award_types).should == [award_type_record]
    end
  end

  describe 'POST create' do
    it 'creates a award_link record and redirects to the listing when successful' do
      award_link_params = {
        name: 'Here we go',
        redirect_url: 'something'
      }

      post :create, {award_link: award_link_params}
      award_link = Plink::AwardLinkRecord.last
      award_link.name.should == 'Here we go'
      flash[:notice].should == 'Award link created successfully'

      response.should redirect_to '/award_links'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::AwardLinkRecord.should_receive(:create).with({ 'name' => 'created name', 'partial_path' => 'path.html.haml' }).and_return(double(persisted?: false))

      post :create, {award_link: {name: 'created name', partial_path: 'path.html.haml'}}

      flash[:notice].should == 'Award link could not be created'
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: award_link.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the award_link by id' do
      assigns(:award_link).should == award_link
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: award_link.id, award_link: {name: 'updated name'}}
      award_link.reload.name.should == 'updated name'
      flash[:notice].should == 'Award link updated'
      response.should redirect_to '/award_links'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::AwardLinkRecord.should_receive(:find).with(award_link.id.to_s).and_return(award_link)
      award_link.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: award_link.id, award_link: {name: 'updated name'}}

      flash[:notice].should == 'Award link could not be updated'
      response.should render_template 'edit'
    end
  end
end
