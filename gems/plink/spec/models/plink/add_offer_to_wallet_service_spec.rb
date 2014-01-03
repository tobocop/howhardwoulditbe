require 'spec_helper'

describe Plink::AddOfferToWalletService do
  describe 'initialize' do
    it 'requires an offer' do
      expect { Plink::AddOfferToWalletService.new(user: double) }.to raise_error(KeyError, 'key not found: :offer')
    end

    it 'requires an user' do
      expect { Plink::AddOfferToWalletService.new(offer: double) }.to raise_error(KeyError, 'key not found: :user')
    end
  end

  describe '#add_offer' do
    let(:user) { double(id: 1) }
    let(:offer) { double(advertisers_rev_share: 0.05) }
    let(:offer_virtual_currency_for_user) { double(id: 123) }

    subject { Plink::AddOfferToWalletService.new(user: user, offer: offer) }

    context 'when user has an empty wallet item' do
      context 'when the offer has a valid offers virtual currency for this user' do
        it 'updates the first available wallet item in the user wallet to set this offer and returns true' do
          award_period = double
          Plink::UsersAwardPeriodRecord.stub(:create) { award_period }
          Plink::AddOfferToWalletService.any_instance.stub(:offer_virtual_currency_for_user) { offer_virtual_currency_for_user }
          wallet_item = double
          user.stub(:open_wallet_item) { wallet_item }
          wallet_item.should_receive(:assign_offer).with(offer_virtual_currency_for_user, award_period) { true }
          subject.add_offer.should == true
        end

        it 'creates an users award period for the wallet item' do
          Plink::AddOfferToWalletService.any_instance.stub(:offer_virtual_currency_for_user) { offer_virtual_currency_for_user }
          wallet_item = double
          user.stub(:open_wallet_item) { wallet_item }
          wallet_item.stub(:assign_offer)

          Plink::UsersAwardPeriodRecord.should_receive(:create).with(user_id: 1, begin_date: Time.zone.today, advertisers_rev_share: 0.05, offers_virtual_currency_id: 123)
          subject.add_offer
        end
      end

      context 'when there is no valid offer virtual currency for the user' do
        it 'returns false' do
          user.stub(:open_wallet_item) { double }
          subject.stub(:offer_virtual_currency_for_user) { nil }
          subject.add_offer.should == false
        end
      end
    end

    context 'when user does not have an empty wallet item' do
      it 'returns false' do
        user.stub(:open_wallet_item) { nil }
        subject.stub(:offer_virtual_currency_for_user)
        subject.add_offer.should == false
      end
    end
  end

  describe 'offer_virtual_currency_for_user' do
    it 'returns an offer virtual currency when it matches the user virtual currency id' do
      user = double(primary_virtual_currency_id: 123)
      offer_virtual_currency = double(virtual_currency_id: 123)
      offer = double(active_offers_virtual_currencies: [offer_virtual_currency])

      service = Plink::AddOfferToWalletService.new(user: user, offer: offer)

      service.offer_virtual_currency_for_user.should == offer_virtual_currency
    end

    it 'returns nil if no offer virtual currencies match the user primary virtual currency' do
      user = double(primary_virtual_currency_id: 123)
      offer_virtual_currency = double(virtual_currency_id: 456)
      offer = double(active_offers_virtual_currencies: [offer_virtual_currency])

      service = Plink::AddOfferToWalletService.new(user: user, offer: offer)

      service.offer_virtual_currency_for_user.should == nil
    end
  end
end
