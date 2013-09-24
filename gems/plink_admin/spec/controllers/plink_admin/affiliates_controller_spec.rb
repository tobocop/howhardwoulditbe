require 'spec_helper'

describe PlinkAdmin::AffiliatesController do
  let(:admin) { create_admin }
  let!(:affiliate) { create_affiliate }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all affiliates in the database' do
      assigns(:affiliates).should == [affiliate]
    end
  end

  describe 'GET new' do
    before { get :new }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets a new affiliate' do
      assigns(:affiliate).should be_present
      assigns(:affiliate).should_not be_persisted
    end
  end

  describe 'POST create' do
    it 'creates a affiliate record and redirects to the listing when successful' do
      affiliate_params = {
        name: 'Created name',
        card_registration_dollar_award_amount: 1.34,
        join_dollar_award_amount: 1.34,
        card_add_pixel: '<img src="http://example.com/image.png />',
        email_add_pixel: '<img src="http://example.com/image.png />',
        disclaimer_text: 'some disclaimer stuff',
      }

      post :create, {affiliate: affiliate_params}
      affiliate = Plink::AffiliateRecord.last
      affiliate.name.should == 'Created name'
      affiliate.card_registration_dollar_award_amount.should == 1.34
      affiliate.has_incented_card_registration.should == true
      affiliate.join_dollar_award_amount.should == 1.34
      affiliate.has_incented_join.should == true
      affiliate.card_add_pixel.should == '<img src="http://example.com/image.png />'
      affiliate.email_add_pixel.should == '<img src="http://example.com/image.png />'
      affiliate.disclaimer_text.should == 'some disclaimer stuff'

      response.should redirect_to '/affiliates'
    end

    it 're-renders the new form when the record cannot be persisted' do
      Plink::AffiliateRecord.should_receive(:create).with({ 'name' => 'created name' }).and_return(double(persisted?: false))

      post :create, {affiliate: {name: 'created name'}}

      response.should render_template 'new'
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: affiliate.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the affiliate by id' do
      assigns(:affiliate).should == affiliate
    end
  end

  describe 'PUT update' do
    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: affiliate.id, affiliate: {name: 'updated name'}}
      affiliate.reload.name.should == 'updated name'
      response.should redirect_to '/affiliates'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::AffiliateRecord.should_receive(:find).with(affiliate.id.to_s).and_return(affiliate)
      affiliate.should_receive(:update_attributes).with({ 'name' => 'updated name' }).and_return(false)

      put :update, {id: affiliate.id, affiliate: {name: 'updated name'}}

      response.should render_template 'edit'
    end
  end
end
