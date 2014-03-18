require 'spec_helper'

describe PlinkAdmin::ReceiptPromotionsController do
  let(:admin) { create_admin }
  let!(:receipt_promotion) { create_receipt_promotion }
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

    it 'gets all receipt_promotions in the database' do
      assigns(:receipt_promotions).should == [receipt_promotion]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new receipt_promotion' do
      assigns(:receipt_promotion).should be_present
      assigns(:receipt_promotion).should_not be_persisted
    end

    it 'gets all award types in the database' do
      assigns(:award_types).should == [award_type_record]
    end
  end

  describe 'POST create' do
    it 'creates a receipt_promotion record and redirects to the listing when successful' do
      receipt_promotion_params = {
        award_type_id: 2,
        name: 'Here we go'
      }

      post :create, {receipt_promotion: receipt_promotion_params}
      receipt_promotion = Plink::ReceiptPromotionRecord.last
      receipt_promotion.name.should == 'Here we go'
      flash[:notice].should == 'Receipt promotion created successfully'

      response.should redirect_to '/receipt_promotions'
    end

    it 're-renders the new form when the record cannot be persisted' do
      controller.stub(:get_data)
      Plink::ReceiptPromotionRecord.should_receive(:create).with(
        {
          'name' => 'created name',
          'partial_path' => 'path.html.haml'
        }
      ).and_return(double(persisted?: false))

      post :create, {receipt_promotion: {name: 'created name', partial_path: 'path.html.haml'}}

      flash[:notice].should == 'Receipt promotion could not be created'
      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: receipt_promotion.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the receipt_promotion by id' do
      assigns(:receipt_promotion).should == receipt_promotion
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: receipt_promotion.id, receipt_promotion: {name: 'updated name'}}
      receipt_promotion.reload.name.should == 'updated name'
      flash[:notice].should == 'Receipt promotion updated'
      response.should redirect_to '/receipt_promotions'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::ReceiptPromotionRecord.should_receive(:find).with(receipt_promotion.id.to_s).and_return(receipt_promotion)
      receipt_promotion.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: receipt_promotion.id, receipt_promotion: {name: 'updated name'}}

      flash[:notice].should == 'Receipt promotion could not be updated'
      response.should render_template 'edit'
    end
  end
end
