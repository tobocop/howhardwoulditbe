require 'spec_helper'

describe "wallet:alter_prc_getUsersWalletByWalletID",  skip_in_build: true do
  include_context "legacy_wallet_items"
  include_context "rake"

  before do
    create_legacy_wallet_item('open', wallet_slot_id: 1)
    create_legacy_wallet_item('open', wallet_slot_id: 2)
    create_legacy_wallet_item('open', wallet_slot_id: 3)
    create_legacy_wallet_slot
    Rake.application.rake_require("lib/tasks/wallet_items", [Rails.root.to_s])
  end

  it 'returns the same values after running the task' do
    original_values = Plink::WalletRecord.execute_procedure(:prc_getUsersWalletByWalletID, wallet.id)
    grouped_original_values = original_values.map { |value| value['slotStatus'] }.group_by { |elem| elem }
    grouped_original_values['unassignedSlot'].length.should == 3
    grouped_original_values['lockedSlot'].length.should == 2

    # Running the alter against the stored proc requires the legacy wallet items to be migrated first
    rake['wallet_items:migrate'].invoke

    subject.invoke

    new_values = Plink::WalletRecord.execute_procedure(:prc_getUsersWalletByWalletID, wallet.id)
    grouped_new_values = new_values.map { |value| value['slotStatus'] }.group_by { |elem| elem }
    grouped_new_values['unassignedSlot'].length.should == grouped_original_values['unassignedSlot'].length
    grouped_new_values['lockedSlot'].length.should == grouped_original_values['lockedSlot'].length
  end

end
