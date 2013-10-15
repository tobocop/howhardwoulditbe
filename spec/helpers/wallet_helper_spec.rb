require 'spec_helper'

describe WalletHelper do
  describe '#show_promotional_wallet_item' do
    let(:valid_wallet) { double(has_unlocked_promotion_slot: false) }
    let(:invalid_wallet) { double(has_unlocked_promotion_slot: true) }

    context 'for a promotion that is current' do
      before do
        helper.stub(end_promotion_date: 1.day.from_now)
      end

      it 'returns true if the user also has not unlocked the promotion slot' do
        helper.show_promotional_wallet_item(valid_wallet).should be_true
      end

      it 'returns false if the user has already unlocked the promotion slot' do
        helper.show_promotional_wallet_item(invalid_wallet).should be_false
      end
    end

    context 'for a promotion that has ended' do
      it 'returns false' do
        helper.stub(end_promotion_date: 1.day.ago)
        helper.show_promotional_wallet_item(valid_wallet).should be_false
      end
    end
  end
end