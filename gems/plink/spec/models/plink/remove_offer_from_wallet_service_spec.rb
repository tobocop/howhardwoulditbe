require 'spec_helper'

describe Plink::RemoveOfferFromWalletService do
  describe 'initialize' do
    it 'requires an offer' do
      expect { Plink::RemoveOfferFromWalletService.new(user: stub) }.to raise_error(KeyError, 'key not found: :offer')
    end

    it 'requires an user' do
      expect { Plink::RemoveOfferFromWalletService.new(offer: stub) }.to raise_error(KeyError, 'key not found: :user')
    end
  end


  describe '#remove_offer' do
    let(:user) { double }
    let(:offer_virtual_currency_for_user) { double }
    let(:users_award_period) { create_users_award_period }
    let!(:wallet_item) { double(users_award_period_id: users_award_period.id, unassign_offer: true) }

    subject { Plink::RemoveOfferFromWalletService.new(user: user, offer: double) }

    context 'when a user has the offer virtual currency in their wallet' do
      it 'nils out offers_virtual_currency_id on wallet_item' do
        Plink::WalletItemHistoryRecord.stub(:clone_from_wallet_item)
        wallet_item.should_receive(:unassign_offer)
        subject.stub(:wallet_item_for_offer) { wallet_item }

        subject.remove_offer
      end

      it 'clones itself to a WalletItemHistoryRecord' do
        Plink::WalletItemHistoryRecord.should_receive(:clone_from_wallet_item).with(wallet_item)
        subject.stub(:wallet_item_for_offer) { wallet_item }

        subject.remove_offer
      end

      it 'sets the usersAwardPeriod.endDate to the current date/time' do
        Plink::WalletItemHistoryRecord.stub(:clone_from_wallet_item)
        subject.stub(:wallet_item_for_offer) { wallet_item }

        subject.remove_offer

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

  describe 'wallet_item_for_offer' do
    it 'returns the wallet item from the user wallet' do
      offers_virtual_currency = stub
      wallet_item = stub
      wallet = stub

      service = Plink::RemoveOfferFromWalletService.new(user: stub, offer: stub)
      service.stub(wallet: wallet)
      service.stub(offer_virtual_currency_for_user: offers_virtual_currency)

      wallet.should_receive(:wallet_item_for_offer).with(offers_virtual_currency) { wallet_item }
      service.wallet_item_for_offer.should == wallet_item
    end

    context 'when offer_virtual_currency_for_user is nil' do
      it 'returns nil' do
        service = Plink::RemoveOfferFromWalletService.new(user: stub, offer: stub)
        service.stub(offer_virtual_currency_for_user: nil)

        service.wallet_item_for_offer.should == nil
      end
    end
  end

  describe 'wallet' do
    it 'returns the user wallet' do
      user = stub
      wallet = stub
      user.stub(wallet: wallet)
      service = Plink::RemoveOfferFromWalletService.new(user: user, offer: stub)

      service.wallet.should == wallet
    end
  end


  describe 'offer_virtual_currency_for_user' do
    it 'returns an offer virtual currency when it matches the user virtual currency id' do
      user = stub(primary_virtual_currency_id: 123)
      offer_virtual_currency = stub(virtual_currency_id: 123)
      offer = stub(active_offers_virtual_currencies: [offer_virtual_currency])

      service = Plink::RemoveOfferFromWalletService.new(user: user, offer: offer)

      service.offer_virtual_currency_for_user.should == offer_virtual_currency
    end

    it 'returns nil if no offer virtual currencies match the user primary virtual currency' do
      user = stub(primary_virtual_currency_id: 123)
      offer_virtual_currency = stub(virtual_currency_id: 456)
      offer = stub(active_offers_virtual_currencies: [offer_virtual_currency])

      service = Plink::RemoveOfferFromWalletService.new(user: user, offer: offer)

      service.offer_virtual_currency_for_user.should == nil
    end
  end
end