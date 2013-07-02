require 'spec_helper'

describe Plink::AddOfferToWalletService do
  describe 'initialize' do
    it 'requires an offer' do
      expect { Plink::AddOfferToWalletService.new(user: stub) }.to raise_error(KeyError, 'key not found: :offer')
    end

    it 'requires an user' do
      expect { Plink::AddOfferToWalletService.new(offer: stub) }.to raise_error(KeyError, 'key not found: :user')
    end
  end

  describe '#add_offer' do
    let(:user) { stub }
    let(:offer_virtual_currency_for_user) { stub }

    subject { Plink::AddOfferToWalletService.new(user: user, offer: stub) }

    context 'when user has an empty wallet item' do
      context 'when the offer has a valid offers virtual currency for this user' do
        it 'updates the first available wallet item in the user wallet to set this offer and returns true' do
          Plink::AddOfferToWalletService.any_instance.stub(:offer_virtual_currency_for_user) { offer_virtual_currency_for_user }
          wallet_item = stub
          user.stub(:empty_wallet_item) { wallet_item }
          wallet_item.should_receive(:assign_offer).with(offer_virtual_currency_for_user) { true }
          subject.add_offer.should == true
        end
      end

      context 'when there is no valid offer virtual currency for the user' do
        it 'returns false' do
          user.stub(:empty_wallet_item) { stub }
          subject.stub(:offer_virtual_currency_for_user) { nil }
          subject.add_offer.should == false
        end
      end
    end

    context 'when user does not have an empty wallet item' do
      it 'returns false' do
        user.stub(:empty_wallet_item) { nil }
        subject.stub(:offer_virtual_currency_for_user)
        subject.add_offer.should == false
      end
    end
  end

  describe 'offer_virtual_currency_for_user' do
    it 'returns an offer virtual currency when it matches the user virtual currency id' do
      user = stub(primary_virtual_currency_id: 123)
      offer_virtual_currency = stub(virtual_currency_id: 123)
      offer = stub(active_offers_virtual_currencies: [offer_virtual_currency])

      service = Plink::AddOfferToWalletService.new(user: user, offer: offer)

      service.offer_virtual_currency_for_user.should == offer_virtual_currency
    end

    it 'returns nil if no offer virtual currencies match the user primary virtual currency' do
      user = stub(primary_virtual_currency_id: 123)
      offer_virtual_currency = stub(virtual_currency_id: 456)
      offer = stub(active_offers_virtual_currencies: [offer_virtual_currency])

      service = Plink::AddOfferToWalletService.new(user: user, offer: offer)

      service.offer_virtual_currency_for_user.should == nil
    end
  end
end