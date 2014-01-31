require 'spec_helper'

describe PlinkAdmin::CompaniesController do
  let(:admin) { create_admin }
  let!(:advertiser) { create_advertiser }
  let!(:company) { create_company }
  let!(:sales_rep) { create_sales_rep }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all companies in the database' do
      assigns(:companies).should == [company]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new company' do
      assigns(:company).should be_present
      assigns(:company).should_not be_persisted
    end

    it 'gets all advertisers in the database' do
      assigns(:advertisers).should be_present
    end

    it 'gets all sales reps in the database' do
      assigns(:sales_reps).should be_present
    end
  end

  describe 'POST create' do
    it 'creates a company record and redirects to the listing when successful' do
      company_params = {
        advertiser_id: 2,
        name: 'Created name',
        prospect: false,
        sales_rep_id: 1,
        vanity_url: 'TD',
      }

      post :create, {company: company_params}
      company = Plink::CompanyRecord.last
      company.name.should == 'Created name'

      response.should redirect_to '/companies'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::CompanyRecord.should_receive(:create).with({ 'name' => 'created name' }).and_return(double(persisted?: false))

      post :create, {company: {name: 'created name'}}

      flash[:notice].should == 'Company could not be created'
      assigns(:advertisers).should be_present
      assigns(:sales_reps).should be_present
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: company.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the company by id' do
      assigns(:company).should == company
    end

    it 'gets all advertisers in the database' do
      assigns(:advertisers).should be_present
    end

    it 'gets all sales reps in the database' do
      assigns(:sales_reps).should be_present
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: company.id, company: {name: 'updated name'}}
      company.reload.name.should == 'updated name'
      flash[:notice].should == 'Company updated'
      response.should redirect_to '/companies'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::CompanyRecord.should_receive(:find).with(company.id.to_s).and_return(company)
      company.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: company.id, company: {name: 'updated name'}}

      flash[:notice].should == 'Company could not be updated'
      assigns(:advertisers).should be_present
      assigns(:sales_reps).should be_present
      response.should render_template 'edit'
    end
  end
end
