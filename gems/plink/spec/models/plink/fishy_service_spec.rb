require 'spec_helper'

describe Plink::FishyService do
  describe '.user_fishy?' do
    let(:intuit_fishy_transactions) { [double(Plink::IntuitFishyTransactionRecord)] }

    before do
      Plink::IntuitFishyTransactionRecord.stub(:active_by_user_id).and_return(intuit_fishy_transactions)
    end

    it 'looks up the users active fishy transactions' do
      Plink::IntuitFishyTransactionRecord.should_receive(:active_by_user_id).with(34).and_return(intuit_fishy_transactions)

      Plink::FishyService.user_fishy?(34)
    end

    context 'when a user has active fishy transactions' do
      it 'returns true' do
        Plink::FishyService.user_fishy?(2).should be_true
      end
    end

    context 'when a user does not have active fishy transactions' do
      let(:intuit_fishy_transactions) { [] }

      it 'returns false' do
        Plink::FishyService.user_fishy?(2).should be_false
      end
    end
  end
end
