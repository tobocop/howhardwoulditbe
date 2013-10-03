require 'spec_helper'

describe Plink::RemoveOfferFromWalletService do
  let(:user) { double(id: 1, primary_virtual_currency_id: 3) }
  let(:offer_virtual_currency) { double(virtual_currency_id: 3) }
  let(:offer) { double(id: 4, active_offers_virtual_currencies: [offer_virtual_currency]) }

  subject(:service) { Plink::RemoveOfferFromWalletService.new(user.id, offer.id) }

  before do
    Plink::UserRecord.should_receive(:find).with(1).and_return(user)
    Plink::OfferRecord.should_receive(:find).with(4).and_return(offer)
  end

  describe '#remove_offer' do
    let(:offer_virtual_currency_for_user) { double }
    let(:users_award_period) { create_users_award_period }
    let!(:wallet_item) { double(users_award_period_id: users_award_period.id, unassign_offer: true) }

    context 'when a user has the offer virtual currency in their wallet' do
      it 'nils out offers_virtual_currency_id on wallet_item' do
        Plink::WalletItemHistoryRecord.stub(:clone_from_wallet_item)
        wallet_item.should_receive(:unassign_offer)
        service.stub(:wallet_item_for_offer) { wallet_item }

        service.remove_offer
      end

      it 'clones itself to a WalletItemHistoryRecord' do
        Plink::WalletItemHistoryRecord.should_receive(:clone_from_wallet_item).with(wallet_item)
        service.stub(:wallet_item_for_offer) { wallet_item }

        service.remove_offer
      end

      it 'sets the usersAwardPeriod.endDate to the current date/time' do
        Plink::WalletItemHistoryRecord.stub(:clone_from_wallet_item)
        service.stub(:wallet_item_for_offer) { wallet_item }

        service.remove_offer

        users_award_period.reload.end_date.to_date.should == Date.current
      end
    end

    context 'when a user does not have the offer virtual currency' do
      it 'returns true' do
        subject.stub(:wallet_item_for_offer)
        subject.remove_offer.should == true
      end
    end
  end
end