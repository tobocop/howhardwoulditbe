require 'spec_helper'

describe Plink::WalletQueryService do
  describe '.initialize' do
    it 'can initialize with an active record relation' do
      scope = Plink::WalletRecord.all
      wallet_query_service = Plink::WalletQueryService.new(scope)
      wallet_query_service.relation.should == scope
    end

    it 'defaults to the wallet record scoped if no relation is provided' do
      wallet_query_service = Plink::WalletQueryService.new
      wallet_query_service.relation.should == Plink::WalletRecord.scoped
    end
  end

  describe '#plink_point_users_with_wallet' do
    let!(:virtual_currency) { create_virtual_currency }
    let!(:user) { create_user(first_name: 'bob', email: 'omally@plink.com') }
    let!(:wallet) { create_wallet(user_id: user.id) }

    before do
      swagbucks_virtual_currency = create_virtual_currency(subdomain: 'swagbucks')
      user = create_user(email: 'machete_dos@example.com')
      user.primary_virtual_currency = swagbucks_virtual_currency
      user.save
      create_wallet(user_id: user.id)
    end

    context 'without a relation provided' do
      subject(:wallet_query_service) { Plink::WalletQueryService.new }

      it 'returns a users first name, email address, along with the correct wallet' do
        plink_point_users_with_wallet = wallet_query_service.plink_point_users_with_wallet
        plink_point_users_with_wallet.length.should == 1
        plink_point_users_with_wallet.first.firstName.should == 'bob'
        plink_point_users_with_wallet.first.emailAddress.should == 'omally@plink.com'
        plink_point_users_with_wallet.first.id.should == wallet.id
      end
    end

    context 'with a relation provided' do
      let(:relation) { Plink::WalletRecord.select('walletID + 1 as plus_one') }

      subject(:wallet_query_service) { Plink::WalletQueryService.new(relation) }

      it 'returns a users first name, email address, along with the correct wallet data including the relation' do
        plink_point_users_with_wallet = wallet_query_service.plink_point_users_with_wallet
        plink_point_users_with_wallet.length.should == 1
        plink_point_users_with_wallet.first.firstName.should == 'bob'
        plink_point_users_with_wallet.first.emailAddress.should == 'omally@plink.com'
        plink_point_users_with_wallet.first.id.should == wallet.id
        plink_point_users_with_wallet.first.plus_one == wallet.id + 1
      end
    end
  end
end
