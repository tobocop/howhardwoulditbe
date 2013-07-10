require 'spec_helper'

describe Plink::WalletItemService do

  describe 'get_for_user_id' do
    let(:user) {create_user}
    let(:wallet) {create_wallet(user_id:user.id)}

    before do
      create_empty_wallet_item(wallet_id: wallet.id)
      create_locked_wallet_item(wallet_id: wallet.id)
    end

    it 'returns wallet_items for a given user_id' do
      wallet_items = Plink::WalletItemService.new.get_for_wallet_id(wallet.id)
      wallet_items.length.should == 2
      wallet_items.map(&:class).uniq.should == [Plink::WalletItem]
    end
  end
end