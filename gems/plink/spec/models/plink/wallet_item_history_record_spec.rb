require 'spec_helper'

describe Plink::WalletItemHistoryRecord do
  subject { Plink::WalletItemHistoryRecord.new(wallet_id: 173, wallet_slot_id: 3, wallet_slot_type_id: 5, users_award_period_id:7, wallet_item_id: 9, offers_virtual_currency_id: 11) }

  it_behaves_like(:legacy_timestamps)

  it 'is valid' do
    subject.save!
  end

  describe '.clone_from_wallet_item' do
    let(:wallet_item_params) { {"walletItemID"=>1, "walletID"=>2, "advertiserID_old"=>nil, "virtualCurrencyID_old"=>nil, "usersAwardPeriodID"=>3, "created"=> Time.now, "modified"=> Time.now, "isActive"=>true, "walletSlotID"=>4, "walletSlotTypeID"=>5, "offersVirtualCurrencyID"=>6} }

    it 'creates a new WalletItemHistoryRecord from attributes' do
      wallet_item = stub(attributes: wallet_item_params)

      expect { Plink::WalletItemHistoryRecord.clone_from_wallet_item(wallet_item) }.to change { Plink::WalletItemHistoryRecord.count }.by(1)

      history_record = Plink::WalletItemHistoryRecord.last
      history_record.wallet_item_id.should == 1
      history_record.wallet_id.should == 2
      history_record.users_award_period_id.should == 3
      history_record.wallet_slot_id.should == 4
      history_record.wallet_slot_type_id.should == 5
      history_record.offers_virtual_currency_id.should == 6
    end
  end
end