require 'spec_helper'

describe "wallet:migrate_wallet_items" do
  include_context "rake"
  include_context "legacy_wallet_items"

  it 'updates the types to the correct class name' do
    legacy_open_wallet_item.type.should be_nil
    legacy_populated_wallet_item.type.should be_nil

    subject.invoke

    legacy_open_wallet_item.reload.type.should == 'Plink::OpenWalletItemRecord'
    legacy_populated_wallet_item.reload.type.should == 'Plink::PopulatedWalletItemRecord'
  end

  context 'number of wallet items should = 5' do
    it 'inserts 2 locked slots for existing users with 3 wallet item slots' do
      3.times {create_legacy_wallet_item('open')}

      subject.invoke

      wallet_items = Plink::WalletItemRecord.all

      grouped_items = wallet_items.map(&:type).group_by {|elem| elem }
      grouped_items['Plink::LockedWalletItemRecord'].length.should == 2

      wallet_items.should have(5).items
    end

    it 'inserts 1 locked slot for existing users with 4 wallet item slots' do
      4.times {create_legacy_wallet_item('open')}

      subject.invoke

      wallet_items = Plink::WalletItemRecord.all

      grouped_items = wallet_items.map(&:type).group_by {|elem| elem }
      grouped_items['Plink::LockedWalletItemRecord'].length.should == 1

      wallet_items.should have(5).items
    end

    it 'inserts 0 locked slots for existing users with 5 wallet item slots' do
      5.times {create_legacy_wallet_item('open')}

      subject.invoke

      wallet_items = Plink::WalletItemRecord.all

      grouped_items = wallet_items.map(&:type).group_by {|elem| elem }
      grouped_items['Plink::LockedWalletItemRecord'].should be_nil

      wallet_items.should have(5).items
    end
  end

end