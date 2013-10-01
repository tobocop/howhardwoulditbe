require 'spec_helper'

describe PlinkAdmin::OffersController do
  let(:admin) { create_admin }
  let!(:offer) { create_offer }

  before do
    sign_in :admin, admin
  end

  describe 'GET index' do
    before { get :index }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets all offers in the database' do
      assigns(:offers).should == [offer]
    end
  end

  describe 'GET edit' do
    before { get :edit, {id: offer.id} }

    it 'responds with a 200' do
      response.status.should == 200
    end

    it 'gets the offer by id' do
      assigns(:offer).should == offer
    end
  end

  describe 'PUT update' do
    let(:end_date) { { 'end_date(1i)'=>'2013', 'end_date(2i)'=>'9', 'end_date(3i)'=>'25'} }

    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: offer.id, offer: end_date}
      offer.reload.end_date.should == Time.zone.local(2013, 9, 25)
      flash[:notice].should == 'Offer end date updated'
      response.should redirect_to '/offers'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::OfferRecord.should_receive(:find).with(offer.id.to_s).and_return(offer)
      offer.should_receive(:update_attribute).and_return(false)

      put :update, {id: offer.id, offer: end_date}

      flash[:notice].should == 'Offer could not be updated'
      response.should render_template 'edit'
    end
  end
end
