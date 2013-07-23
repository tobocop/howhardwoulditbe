require 'spec_helper'

describe WalletOffersController do
  let(:offer_id) { '1' }
  describe '#create' do
    context 'when the user is logged in' do
      before do
        controller.stub(:user_must_be_linked) { nil }
        @user = set_current_user
        @virtual_currency = set_virtual_currency(currency_name: 'Bit Bucks', amount_in_currency: 24)
      end

      it 'raises an exception if user is not linked' do
        controller.stub(:user_must_be_linked) { raise }
        expect { post :create, offer_id: offer_id }.to raise_error
      end

      it 'adds the offer to the user wallet' do
        offer = stub
        Plink::OfferRecord.stub(:live_only).with(offer_id) { offer }

        service = stub
        Plink::AddOfferToWalletService.should_receive(:new).with(user: @user, offer: offer) { service }

        service.should_receive(:add_offer)

        post :create, offer_id: offer_id
      end

      it 'returns a JSON representation of the wallet if the service is successful' do
        set_current_user(wallet: stub(id: 3))

        wallet_items_service = stub
        wallet_item = Plink::WalletItem.new(new_populated_wallet_item)
        fake_offer = stub(:fake_offer, image_url: 'booyah.jpg', name: 'Best Buy', is_new: false, max_dollar_award_amount: 30, id: 8)
        wallet_item.stub(:offer) { fake_offer }
        wallet_items_service.should_receive(:get_for_wallet_id).with(3) { [wallet_item] }

        Plink::WalletItemService.should_receive(:new) { wallet_items_service }

        Plink::OfferRecord.stub(:live_only) { stub }
        Plink::AddOfferToWalletService.any_instance.stub(:add_offer) { true }
        post :create, offer_id: offer_id
        response.status.should == 201
        JSON.parse(response.body)['wallet'].should == [
            'template_name' => 'populated_wallet_item',
            'icon_url' => '/booyah.jpg',
            'special_offer_type' => nil,
            'special_offer_type_text' => nil,
            'icon_description' => 'Best Buy',
            'currency_name' => 'Bit Bucks',
            'max_currency_award_amount' => 24,
            'wallet_offer_url' => 'http://test.host/wallet/offers/8'
        ]
      end

      it 'renders an error if offer cannot be found' do
        Plink::OfferRecord.stub(:live_only) { raise ActiveRecord::RecordNotFound }
        expect { post :create, offer_id: offer_id }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'returns a failure reason of wallet_full if the service fails' do
        Plink::OfferRecord.stub(:live_only) { stub }
        Plink::AddOfferToWalletService.any_instance.stub(:add_offer) { false }
        post :create, offer_id: offer_id

        JSON.parse(response.body)['failure_reason'].should == 'wallet_full'
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
      @virtual_currency = set_virtual_currency(currency_name: 'Bit Bucks', amount_in_currency: 24)
    end

    it 'returns a JSON representation of the refreshed wallet and the item that was removed' do
      user = set_current_user(wallet: stub(id: 3))

      remaining_offer = stub(:wallet_item_offer, image_url: 'something.jpg', is_new: true, name: 'Amazon', max_dollar_award_amount: 25, id: 7)
      removed_offer_record = stub(:fake_offer, image_url: 'booyah.jpg', name: 'Best Buy', max_dollar_award_amount: 30, id: 8)
      Plink::OfferRecord.stub(:find).with(offer_id) { removed_offer_record }
      removed_offer = stub(:removed_offer)
      Plink::Offer.stub(:new).and_return(removed_offer)

      wallet_items_service = stub
      wallet_item = Plink::WalletItem.new(new_populated_wallet_item)
      wallet_item.stub(:offer) { remaining_offer }
      wallet_items_service.should_receive(:get_for_wallet_id).with(3) { [wallet_item] }
      Plink::WalletItemService.should_receive(:new) { wallet_items_service }

      service = stub
      Plink::RemoveOfferFromWalletService.should_receive(:new).with(user: user, offer: removed_offer_record) { service }
      service.should_receive(:remove_offer).and_return(true)

      OfferItemPresenter.should_receive(:new).with(removed_offer, virtual_currency: @virtual_currency, view_context: anything, linked: false, signed_in: true)

      delete :destroy, id: offer_id

      JSON.parse(response.body)['wallet'].should == [
        'template_name' => 'populated_wallet_item',
        'icon_url' => '/something.jpg',
        'icon_description' => 'Amazon',
        'special_offer_type' => 'ribbon-new-offer',
        'special_offer_type_text' => 'New Partner!',
        'currency_name' => 'Bit Bucks',
        'max_currency_award_amount' => 24,
        'wallet_offer_url' => 'http://test.host/wallet/offers/7'
      ]

    end

    it 'redirects the user if they are not logged in' do
      controller.stub(:user_logged_in?) { false }
      delete :destroy, id: 1
      response.should be_redirect
    end
  end
end