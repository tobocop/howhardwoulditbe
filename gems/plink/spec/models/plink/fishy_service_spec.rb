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

  describe '.fishy_with' do
    let(:intuit_fishy_transaction_records) {
      [
        double(Plink::IntuitFishyTransactionRecord, user_id: 2, other_fishy_user_id: 3),
        double(Plink::IntuitFishyTransactionRecord, user_id: 2, other_fishy_user_id: 3),
        double(Plink::IntuitFishyTransactionRecord, user_id: 2, other_fishy_user_id: 4),
        double(Plink::IntuitFishyTransactionRecord, user_id: 73, other_fishy_user_id: 2),
        double(Plink::IntuitFishyTransactionRecord, user_id: 287, other_fishy_user_id: 2),
        double(Plink::IntuitFishyTransactionRecord, user_id: 287, other_fishy_user_id: 2)
      ]
    }

    before do
      Plink::IntuitFishyTransactionRecord.stub(:active_by_user_id).and_return(intuit_fishy_transaction_records)
    end

    it 'it calls to get all active fishy transactions by user id' do
      Plink::IntuitFishyTransactionRecord.should_receive(:active_by_user_id).with(3).and_return(intuit_fishy_transaction_records)

      Plink::FishyService.fishy_with(3)
    end

    it 'returns a distinct list of user_ids and other_fishy_user_ids ' do
      Plink::FishyService.fishy_with(3).should == [2, 3, 4, 73, 287]
    end
  end
end
