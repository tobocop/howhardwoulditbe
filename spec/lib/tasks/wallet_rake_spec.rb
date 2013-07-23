require 'spec_helper'

describe "wallet:migrate_wallet_items" do
  include_context "rake"

  let(:legacy_open_wallet_item) { create_legacy_wallet_item('open') }
  let(:legacy_populated_wallet_item) { create_legacy_wallet_item('populated') }
  let(:wallet) { create_wallet }

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

  private

  def create_legacy_wallet_item(type)
    period_id = type == 'open' ? nil : 100

    wallet_attrs = {
      :wallet_id => wallet.id,
      :wallet_slot_id => 0,
      :wallet_slot_type_id => 0,
      :users_award_period_id => period_id,
      :offers_virtual_currency_id => nil,
      :type => nil
    }

    #Plink::WalletItemRecord.create(wallet_attrs)
    Plink::WalletItemRecord.new { |record| apply(record, wallet_attrs, {}) }.tap(&:save!)
  end

  def create_legacy_wallet_slot(type)
    period_id = type == 'open' ? nil : 100

    wallet_attrs = {
      :wallet_id => wallet.id,
      :wallet_slot_id => 0,
      :wallet_slot_type_id => 0,
      :users_award_period_id => period_id,
      :offers_virtual_currency_id => nil,
      :type => nil
    }

    #Plink::WalletItemRecord.create(wallet_attrs)
    Plink::WalletItemRecord.new { |record| apply(record, wallet_attrs, {}) }.tap(&:save!)
  end


  def apply(object, defaults, overrides)
    options = defaults.merge(overrides)
    options.each do |method, value_or_proc|
      object.send("#{method}=", value_or_proc.is_a?(Proc) ? value_or_proc.call : value_or_proc)
    end
  end
end