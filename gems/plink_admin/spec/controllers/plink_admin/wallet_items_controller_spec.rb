require 'spec_helper'

describe PlinkAdmin::WalletItemsController do
  let(:admin) { create_admin }

  before :each do
    sign_in :admin, admin
  end

  describe 'POST unlock_wallet_items_with_reason' do
    let(:locked_wallet_item_record) { create_locked_wallet_item }

    context 'with a successful request' do
      let(:params) {
        {id: locked_wallet_item_record.id,
         unlock_reason: ::Plink::WalletRecord::UNLOCK_REASONS[:join]}
      }

      before { post :unlock_wallet_item_with_reason, params }

      it 'returns a success message' do
        JSON.parse(response.body)['message'].should == 'Successfully set for reason of join'
      end

      it 'returns a 200 (OK) HTTP Status Code' do
        response.status.should == 200
      end

      it 'sets the unlock_reason for a given Plink::WalletItemRecord' do
        Plink::WalletItemRecord.find(locked_wallet_item_record.id).type.should == 'Plink::OpenWalletItemRecord'
      end
    end

    context 'with a failed request' do
      let(:params) {
        { id: locked_wallet_item_record.id,
          unlock_reason: ' ' }
      }

      before { post :unlock_wallet_item_with_reason, params }

      it 'returns a 422 (Unprocessible Entity) HTTP Status Code' do
        response.status.should == 422
      end

      it 'returns an error message' do
        JSON.parse(response.body)['message'].should include 'Unable to unlock wallet item record.'
      end

      it 'does not modify the WalletItemRecord' do
        locked_wallet_item_record.type.should == 'Plink::LockedWalletItemRecord'
      end
    end

  end

  describe 'POST give_open_wallet_item_with_reason' do
    let(:wallet) { create_wallet }
    let(:params) { {id: wallet.id, unlock_reason: 'join'} }

    context 'with a successful request' do
      before do
        Plink::WalletItemService.should_receive(:create_open_wallet_item)
          .with(wallet.id.to_s, 'join')
          .and_call_original

        post :give_open_wallet_item_with_reason, params
      end

      it 'returns a success message' do
        JSON.parse(response.body)['message'].should == 'Successfully opened item for reason of join'
      end

      it 'returns a 200 (OK) HTTP Status Code' do
        response.status.should == 200
      end

      it 'creates an open wallet item for the wallet' do
        wallet.reload.open_wallet_items.length.should == 1
      end
    end

    context 'with a failed request' do
      before do
        Plink::WalletItemService.should_receive(:create_open_wallet_item)
          .with(wallet.id.to_s, 'join')
          .and_return(false)

        post :give_open_wallet_item_with_reason, params
      end

      it 'returns an error message' do
        JSON.parse(response.body)['message'].should == 'Unable to open wallet item record'
      end

      it 'returns a 422 (Unprocessible Entity) HTTP Status Code' do
        response.status.should == 422
      end
    end
  end
end
