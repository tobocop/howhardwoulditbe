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
    let(:offer_params) {
      {
        'end_date(1i)'=>"#{3.days.from_now.year}",
        'end_date(2i)'=>"#{3.days.from_now.month}",
        'end_date(3i)'=>"#{3.days.from_now.day}",
        detail_text: 'herp a derp',
        send_expiring_soon_reminder: true,
        show_end_date: true
      }
    }

    it 'updates the record and redirects to the listing when successful' do
      put :update, {id: offer.id, offer: offer_params}

      offer.reload.end_date.should == Time.zone.local(3.days.from_now.year, 3.days.from_now.month, 3.days.from_now.day)
      offer.show_end_date.should be_true
      offer.send_expiring_soon_reminder.should be_true
      offer.detail_text.should == 'herp a derp'
      flash[:notice].should == 'Offer updated'
      response.should redirect_to '/offers'
    end

    it 'does not update the record if the end date is earlier then 3 days from now' do
      date_params = {
        'end_date(1i)'=>"#{2.days.from_now.year}",
        'end_date(2i)'=>"#{2.days.from_now.month}",
        'end_date(3i)'=>"#{2.days.from_now.day}"
      }

      put :update, {id: offer.id, offer: date_params}

      flash[:notice].should == 'Offer could not be updated. The end date for the offer needs to be at least 3 days from today.'
      response.should render_template 'edit'
    end

    it 're-renders the edit form when the record cannot be updated' do
      Plink::OfferRecord.should_receive(:find).with(offer.id.to_s).and_return(offer)
      offer.should_receive(:update_attributes).and_return(false)

      put :update, {id: offer.id, offer: offer_params}

      flash[:notice].should == 'Offer could not be updated'
      response.should render_template 'edit'
    end
  end
end
