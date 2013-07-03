require 'spec_helper'

describe WalletOffersController do
  let(:offer_id) { '1' }

  describe '#create' do
    context 'when the user is logged in' do
      before do
        controller.stub(:user_logged_in?) { true }
        controller.stub(:user_must_be_linked) { nil }
      end

      it 'raises an exception if user is not linked' do
        controller.stub(:user_must_be_linked) { raise }
        expect { post :create, offer_id: offer_id }.to raise_error
      end

      it 'adds the offer to the user wallet' do
        user = stub
        controller.stub(:current_user) { user }

        offer = stub
        Plink::OfferRecord.stub(:live_only).with(offer_id) { offer }

        service = stub
        Plink::AddOfferToWalletService.should_receive(:new).with(user: user, offer: offer) { service }

        service.should_receive(:add_offer)

        post :create, offer_id: offer_id
      end

      it 'returns a successful request if the service is successful' do
        Plink::OfferRecord.stub(:live_only) { stub }
        Plink::AddOfferToWalletService.any_instance.stub(:add_offer) { true }
        post :create, offer_id: offer_id
        response.should be_redirect
      end

      it 'renders an error if offer cannot be found' do
        Plink::OfferRecord.stub(:live_only) { raise ActiveRecord::RecordNotFound }
        expect { post :create, offer_id: offer_id }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns an error if the service fails' do
        Plink::OfferRecord.stub(:live_only) { stub }
        Plink::AddOfferToWalletService.any_instance.stub(:add_offer) { false }
        post :create, offer_id: offer_id
        response.should_not be_successful
      end
    end

    it 'redirects the user if they are not logged in' do
      controller.stub(:user_logged_in?) { false }
      post :create, offer_id: offer_id
      response.should be_redirect
    end
  end

  describe '#destroy' do
    before do
      controller.stub(:user_logged_in?) { true }
      controller.stub(:user_must_be_linked)
    end

    it 'deletes the offer from the user wallet' do
      user = stub
      controller.stub(:current_user) { user }

      offer = stub
      Plink::OfferRecord.stub(:find).with(offer_id) { offer }

      service = stub
      Plink::RemoveOfferFromWalletService.should_receive(:new).with(user: user, offer: offer) { service }

      service.should_receive(:remove_offer)

      delete :destroy, id: offer_id
    end

    it 'redirects the user if they are not logged in' do
      controller.stub(:user_logged_in?) { false }
      delete :destroy, id: 1
      response.should be_redirect
    end
  end
end