require 'spec_helper'

describe PlinkAdmin::ContactsController do
  let(:admin) { create_admin }
  let!(:contact) { create_contact}

  before do
    sign_in :admin, admin
    create_brand
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all contacts in the database' do
      assigns(:contacts).should == [contact]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new contact' do
      assigns(:contact).should be_present
      assigns(:contact).should_not be_persisted
    end

    it 'gets all brands in the database' do
      assigns(:brands).should be_present
    end
  end

  describe 'POST create' do
    it 'creates a contact record and redirects to the listing when successful' do
      contact_params = {
        brand_id: 3,
        email: 'testing@derp.com',
        first_name: 'Here',
        last_name: 'Wego'
      }

      post :create, {contact: contact_params}

      contact = Plink::ContactRecord.last
      contact.brand_id.should == 3
      contact.email.should == 'testing@derp.com'
      contact.first_name.should == 'Here'
      contact.last_name.should == 'Wego'
      flash[:notice].should == 'Contact created successfully'

      response.should redirect_to '/contacts'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::ContactRecord.should_receive(:create).with({ 'first_name' => 'created name', 'partial_path' => 'path.html.haml' }).and_return(double(persisted?: false))

      post :create, {contact: {first_name: 'created name', partial_path: 'path.html.haml'}}

      flash[:notice].should == 'Contact could not be created'
      assigns(:brands).should be_present
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: contact.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the contact by id' do
      assigns(:contact).should == contact
    end

    it 'gets all brands in the database' do
      assigns(:brands).should be_present
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: contact.id, contact: {first_name: 'updated name'}}
      contact.reload.first_name.should == 'updated name'
      flash[:notice].should == 'Contact updated'
      response.should redirect_to '/contacts'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::ContactRecord.should_receive(:find).with(contact.id.to_s).and_return(contact)
      contact.should_receive(:update_attributes).with({ 'first_name' => 'updated name' }).and_return(false)

      put :update, {id: contact.id, contact: {first_name: 'updated name'}}

      flash[:notice].should == 'Contact could not be updated'
      assigns(:brands).should be_present
      response.should render_template 'edit'
    end
  end
end
