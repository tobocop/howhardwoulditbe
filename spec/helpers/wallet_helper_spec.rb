require 'spec_helper'

describe WalletHelper do
  describe '#show_promotional_wallet_item' do

    context 'for a promotion that is current' do
      it 'returns true' do
        helper.stub(end_promotion_date: 1.day.from_now)
        helper.show_promotional_wallet_item.should be_true
      end
    end

    context 'for a promotion that has ended' do
      it 'returns false' do
        helper.stub(end_promotion_date: 1.day.ago)
        helper.show_promotional_wallet_item.should be_false
      end
    end
  end
end