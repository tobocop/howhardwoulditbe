require 'spec_helper'

describe PlinkAdmin::BrandsController do
  let(:admin) { create_admin }
  let!(:advertiser) { create_advertiser }
  let!(:brand) { create_brand }
  let!(:sales_rep) { create_sales_rep }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all brands in the database' do
      assigns(:brands).should == [brand]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new brand' do
      assigns(:brand).should be_present
      assigns(:brand).brand_competitors.should be_present
      assigns(:brand).should_not be_persisted
    end

    it 'gets all sales reps in the database' do
      assigns(:sales_reps).should be_present
    end
  end

  describe 'POST create' do
    it 'creates a brand record and redirects to the listing when successful' do
      brand_params = {
        name: 'Created name',
        prospect: false,
        sales_rep_id: 1,
        vanity_url: 'TD',
      }

      post :create, {brand: brand_params}
      brand = Plink::BrandRecord.last
      brand.name.should == 'Created name'

      response.should redirect_to '/brands'
    end

    it 're-renders the new form when the record cannot be persisted' do
      brand_record = new_brand
      brand_record.stub(:persisted?).and_return(false)
      Plink::BrandRecord.should_receive(:create).with({ 'name' => 'created name' }).and_return(brand_record)

      post :create, {brand: {name: 'created name'}}

      flash[:notice].should == 'Brand could not be created'
      assigns(:sales_reps).should be_present
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: brand.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the brand by id' do
      assigns(:brand).should == brand
    end

    it 'gets all sales reps in the database' do
      assigns(:sales_reps).should be_present
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: brand.id, brand: {name: 'updated name'}}
      brand.reload.name.should == 'updated name'
      flash[:notice].should == 'Brand updated'
      response.should redirect_to '/brands'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::BrandRecord.should_receive(:find).with(brand.id.to_s).and_return(brand)
      brand.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: brand.id, brand: {name: 'updated name'}}

      flash[:notice].should == 'Brand could not be updated'
      assigns(:sales_reps).should be_present
      response.should render_template 'edit'
    end
  end
end
