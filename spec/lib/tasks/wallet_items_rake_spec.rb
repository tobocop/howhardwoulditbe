require 'spec_helper'

describe "wallet_items:migrate", skip_in_build: true do
  include_context "rake"
  include_context "legacy_wallet_items"

  let(:legacy_open_wallet_item) { create_legacy_wallet_item('open', wallet_slot_id: 1) }
  let(:legacy_populated_wallet_item) { create_legacy_wallet_item('populated', wallet_slot_id: 2) }

  it 'updates the types to the correct class name' do
    legacy_open_wallet_item.type.should be_nil
    legacy_populated_wallet_item.type.should be_nil

    subject.invoke

    legacy_open_wallet_item.reload.type.should == 'Plink::OpenWalletItemRecord'
    legacy_populated_wallet_item.reload.type.should == 'Plink::PopulatedWalletItemRecord'
  end

  context 'number of wallet items should = 5' do
    it 'inserts 2 locked slots for existing users with 3 wallet item slots' do
      3.times { create_legacy_wallet_item('open') }

      subject.invoke

      wallet_items = Plink::WalletItemRecord.all

      grouped_items = wallet_items.map(&:type).group_by { |elem| elem }
      grouped_items['Plink::LockedWalletItemRecord'].length.should == 2

      wallet_items.should have(5).items
    end

    it 'inserts 1 locked slot for existing users with 4 wallet item slots' do
      4.times { create_legacy_wallet_item('open') }

      subject.invoke

      wallet_items = Plink::WalletItemRecord.all

      grouped_items = wallet_items.map(&:type).group_by { |elem| elem }
      grouped_items['Plink::LockedWalletItemRecord'].length.should == 1

      wallet_items.should have(5).items
    end

    it 'inserts 0 locked slots for existing users with 5 wallet item slots' do
      5.times { create_legacy_wallet_item('open') }

      subject.invoke

      wallet_items = Plink::WalletItemRecord.all

      grouped_items = wallet_items.map(&:type).group_by { |elem| elem }
      grouped_items['Plink::LockedWalletItemRecord'].should be_nil

      wallet_items.should have(5).items
    end
  end
end

describe 'wallet_items:unlock_transaction_wallet_item', skip_in_build: true do
  include_context 'rake'

  let!(:user_with_no_qualified_transactions) { create_user(email: 'cosmo@example.com') }
  let!(:no_qualified_transactions_wallet) { create_wallet(user_id: user_with_no_qualified_transactions.id) }
  let!(:no_qualified_locked_wallet_item) { create_locked_wallet_item(wallet_id: no_qualified_transactions_wallet.id) }

  let!(:user_with_pending_qualified_transactions) { create_user(email: 'newman@example.com') }
  let!(:pending_qualified_transactions_wallet) { create_wallet(user_id: user_with_pending_qualified_transactions.id) }
  let!(:pending_user_locked_item1) { create_locked_wallet_item(wallet_id: pending_qualified_transactions_wallet.id) }
  let!(:pending_user_locked_item2) { create_open_wallet_item(wallet_id: pending_qualified_transactions_wallet.id) }
  let!(:pending_user_locked_item3) { create_qualifying_award(user_id: user_with_pending_qualified_transactions.id) }

  let!(:user_previously_unlocked) { create_user(email: 'elaine@example.com') }
  let!(:previously_unlocked_wallet) { create_wallet(user_id: user_previously_unlocked.id) }
  let!(:previously_unlocked_award) { create_qualifying_award(user_id: user_previously_unlocked.id) }
  let!(:previously_unlocked_item) { create_open_wallet_item(wallet_id: previously_unlocked_wallet.id, unlock_reason: 'transaction') }

  it 'does not unlock wallet items for users without qualifying transactions' do
    no_qualified_transactions_wallet.locked_wallet_items.size.should == 1
    no_qualified_transactions_wallet.open_wallet_items.should be_empty

    subject.invoke

    no_qualified_transactions_wallet.reload
    no_qualified_transactions_wallet.locked_wallet_items.size.should == 1
    no_qualified_transactions_wallet.open_wallet_items.should be_empty
  end

  it 'unlocks wallet items for eligible users' do
    pending_qualified_transactions_wallet.open_wallet_items.size.should == 1
    pending_qualified_transactions_wallet.locked_wallet_items.size.should == 1

    subject.invoke

    pending_qualified_transactions_wallet.reload
    pending_qualified_transactions_wallet.open_wallet_items.size.should == 2
    pending_qualified_transactions_wallet.locked_wallet_items.size.should == 0
  end

  it 'does not unlock wallet items for users who had previously unlocked' do
    previously_unlocked_wallet.open_wallet_items.size.should == 1
    previously_unlocked_wallet.locked_wallet_items.should be_empty

    subject.invoke

    previously_unlocked_wallet.reload
    previously_unlocked_wallet.open_wallet_items.size.should == 1
    previously_unlocked_wallet.locked_wallet_items.should be_empty
  end
end

describe 'wallet_items:set_unlock_reason', skip_in_build: true do
  include_context 'rake'

  let(:legacy_join_lock_slot_id) { 1 }
  let(:legacy_join_lock_slot_type_id) { 1 }
  let(:legacy_transaction_lock_slot_id) { 2 }
  let(:legacy_transaction_lock_slot_type_id) { 2 }
  let(:legacy_referral_lock_slot_id) { 3 }
  let(:legacy_referral_lock_slot_type_id) { 3 }

  let!(:legacy_wallet_join_only) {
    user = create_user(email: 'daphne@example.com')
    wallet = create_wallet(user_id: user.id)
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_join_lock_slot_id,
      wallet_slot_type_id: legacy_join_lock_slot_type_id
    )
    wallet
  }

  let!(:legacy_transaction_unlock_wallet) {
    user = create_user(email: 'bulldog@example.com')
    wallet = create_wallet(user_id: user.id)
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_join_lock_slot_id,
      wallet_slot_type_id: legacy_join_lock_slot_type_id,
      users_award_period_id: 100
    )
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_transaction_lock_slot_id,
      wallet_slot_type_id: legacy_transaction_lock_slot_type_id,
      users_award_period_id: 101
    )
    wallet
  }

  let!(:legacy_referral_unlock_wallet) {
    user = create_user(email: 'eddie@example.com')
    wallet = create_wallet(user_id: user.id)
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_referral_lock_slot_id,
      wallet_slot_type_id: legacy_referral_lock_slot_type_id,
      users_award_period_id: 200
    )
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_join_lock_slot_id,
      wallet_slot_type_id: legacy_join_lock_slot_type_id,
      users_award_period_id: 201
    )
    wallet
  }

  let!(:legacy_all_unlock_wallet) {
    user = create_user(email: 'lilith@example.com')
    wallet = create_wallet(user_id: user.id)
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_join_lock_slot_id,
      wallet_slot_type_id: legacy_join_lock_slot_type_id,
      users_award_period_id: 300
    )
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_transaction_lock_slot_id,
      wallet_slot_type_id: legacy_transaction_lock_slot_type_id,
      users_award_period_id: 301
    )
    Plink::WalletItemRecord.create!(
      wallet_id: wallet.id,
      wallet_slot_id: legacy_referral_lock_slot_id,
      wallet_slot_type_id: legacy_referral_lock_slot_type_id,
      users_award_period_id: 302
    )
    wallet
  }

  before do
    task_path = "lib/tasks/#{task_name.split(":").first}"
    Rake.application.rake_require(task_path, [Rails.root], loaded_files_excluding_current_rake_file)
    rake['wallet_items:migrate'].invoke
  end

  it 'sets the unlock_reason to transaction for wallet items previously unlocked by a qualifying transaction' do
    Plink::WalletItemRecord.wallets_with_an_unlock_reason_of_transaction.size.should == 0

    subject.invoke

    wallets_with_an_unlock_reason_of_transaction = Plink::WalletItemRecord.wallets_with_an_unlock_reason_of_transaction.map(&:wallet_id)

    wallets_with_an_unlock_reason_of_transaction.should include legacy_transaction_unlock_wallet.walletID
    wallets_with_an_unlock_reason_of_transaction.should include legacy_all_unlock_wallet.walletID
    wallets_with_an_unlock_reason_of_transaction.size.should == 2
  end

  it 'sets the unlock_reason to join for wallet items that were not unlocked by join or transaction' do
    Plink::WalletItemRecord.wallets_with_an_unlock_reason_of_join.size.should == 0

    subject.invoke

    wallets_with_an_unlock_reason_of_join = Plink::WalletItemRecord.wallets_with_an_unlock_reason_of_join.map(&:wallet_id)

    wallets_with_an_unlock_reason_of_join.should include legacy_transaction_unlock_wallet.walletID
    wallets_with_an_unlock_reason_of_join.should include legacy_all_unlock_wallet.walletID
    wallets_with_an_unlock_reason_of_join.should include legacy_referral_unlock_wallet.walletID
    wallets_with_an_unlock_reason_of_join.should include legacy_wallet_join_only.walletID
    wallets_with_an_unlock_reason_of_join.size.should == 4
  end

  it 'sets the unlock_reason to referral for wallet items that were unlocked by referral' do
    Plink::WalletItemRecord.wallets_with_an_unlock_reason_of_referral.size.should == 0

    subject.invoke

    wallets_with_an_unlock_reason_of_referral = Plink::WalletItemRecord.wallets_with_an_unlock_reason_of_referral.map(&:wallet_id)

    wallets_with_an_unlock_reason_of_referral.should include legacy_referral_unlock_wallet.walletID
    wallets_with_an_unlock_reason_of_referral.should include legacy_all_unlock_wallet.walletID

    wallets_with_an_unlock_reason_of_referral.should_not include legacy_wallet_join_only.walletID
    wallets_with_an_unlock_reason_of_referral.should_not include legacy_transaction_unlock_wallet.walletID

    Plink::WalletItemRecord.wallets_with_an_unlock_reason_of_referral.size.should == 2
  end

end

describe "wallet_items:remove_expired_offers", skip_in_build: true do
  include_context "rake"

  let(:virtual_currency) { create_virtual_currency }

  let(:valid_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:valid_offer) {
    create_offer(
      end_date: Date.current,
      offers_virtual_currencies: [valid_offer_offers_virtual_currency]
    )
  }
  let!(:valid_offer_tier_one) { create_tier(offers_virtual_currency_id: valid_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }
  let!(:valid_offer_tier_two) { create_tier(offers_virtual_currency_id: valid_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }

  let(:expired_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:expired_offer) {
    create_offer(
      end_date: Date.yesterday.midnight,
      offers_virtual_currencies: [expired_offer_offers_virtual_currency]
    )
  }
  let!(:expired_offer_tier_one) { create_tier(offers_virtual_currency_id: expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }
  let!(:expired_offer_tier_two) { create_tier(offers_virtual_currency_id: expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }

  let(:another_expired_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:another_expired_offer) {
    create_offer(
      end_date: Date.yesterday.midnight,
      offers_virtual_currencies: [another_expired_offer_offers_virtual_currency]
    )
  }
  let!(:another_expired_offer_tier_one) { create_tier(offers_virtual_currency_id: another_expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }
  let!(:another_expired_offer_tier_two) { create_tier(offers_virtual_currency_id: another_expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }

  let(:user_with_expired_offer) { create_user(email: 'foo@example.com') }
  let(:other_user_with_expired_offer) { create_user(email: 'ichabod@example.com') }
  let(:user_without_expired_offer) { create_user(email: 'loser@example.com') }

  before do
    [user_with_expired_offer, other_user_with_expired_offer, user_without_expired_offer].each do |user|
      create_wallet(
        user_id: user.id,
        wallet_item_records: [new_open_wallet_item, new_open_wallet_item]
      )
    end

    Plink::AddOfferToWalletService.new(user: user_with_expired_offer, offer: expired_offer).add_offer
    Plink::AddOfferToWalletService.new(user: user_with_expired_offer, offer: another_expired_offer).add_offer
    Plink::AddOfferToWalletService.new(user: other_user_with_expired_offer, offer: expired_offer).add_offer
    Plink::AddOfferToWalletService.new(user: other_user_with_expired_offer, offer: valid_offer).add_offer
    Plink::AddOfferToWalletService.new(user: user_without_expired_offer, offer: valid_offer).add_offer
  end

  it 'removes offers that have expired from every wallet' do
    Plink::RemoveOfferFromWalletService.should_receive(:new).exactly(3).times.and_call_original

    subject.invoke

    grouped_items = user_with_expired_offer.wallet.wallet_item_records.map(&:type).group_by { |elem| elem }
    grouped_items['Plink::OpenWalletItemRecord'].length.should == 2
    grouped_items['Plink::PopulatedWalletItemRecord'].should be_nil

    grouped_items = other_user_with_expired_offer.wallet.wallet_item_records.map(&:type).group_by { |elem| elem }
    grouped_items['Plink::OpenWalletItemRecord'].length.should == 1
    grouped_items['Plink::PopulatedWalletItemRecord'].length.should == 1

    grouped_items = user_without_expired_offer.wallet.wallet_item_records.map(&:type).group_by { |elem| elem }
    grouped_items['Plink::OpenWalletItemRecord'].length.should == 1
    grouped_items['Plink::PopulatedWalletItemRecord'].length.should == 1
  end

  it 'only removes offers that have an end_date before today and within the last 7 days' do
    Plink::OfferRecord.should_receive(:where).with('endDate < ? AND endDate > ?', Date.current, 7.days.ago.to_date).and_return([])

    subject.invoke
  end

  it 'end dates all tiers associated to the offer through its offers virtual currencies' do
    expired_offer_tier_one.end_date.should_not == expired_offer.end_date
    expired_offer_tier_two.end_date.should_not == expired_offer.end_date
    another_expired_offer_tier_one.end_date.should_not == another_expired_offer.end_date
    another_expired_offer_tier_two.end_date.should_not == another_expired_offer.end_date
    valid_offer_tier_one.end_date.should_not == valid_offer.end_date
    valid_offer_tier_two.end_date.should_not == valid_offer.end_date

    subject.invoke

    expired_offer_tier_one.reload.end_date.should == expired_offer.end_date
    expired_offer_tier_two.reload.end_date.should == expired_offer.end_date
    another_expired_offer_tier_one.reload.end_date.should == another_expired_offer.end_date
    another_expired_offer_tier_two.reload.end_date.should == another_expired_offer.end_date
    valid_offer_tier_one.end_date.should_not == valid_offer.end_date
    valid_offer_tier_two.end_date.should_not == valid_offer.end_date
  end

  it 'end dates the users_award_period' do
    expiring_users_award_period = Plink::UsersAwardPeriodRecord.where('userID = ? AND offers_virtual_currency_id = ?', user_with_expired_offer.id, expired_offer_offers_virtual_currency.id).first
    another_expiring_users_award_period = Plink::UsersAwardPeriodRecord.where('userID = ? AND offers_virtual_currency_id = ?', user_with_expired_offer.id, another_expired_offer_offers_virtual_currency.id).first
    other_users_expiring_users_award_period = Plink::UsersAwardPeriodRecord.where('userID = ? AND offers_virtual_currency_id = ?', other_user_with_expired_offer.id, expired_offer_offers_virtual_currency.id).first
    other_users_non_expiring_users_award_period = Plink::UsersAwardPeriodRecord.where('userID = ? AND offers_virtual_currency_id = ?', other_user_with_expired_offer.id, valid_offer_offers_virtual_currency.id).first
    non_expiring_users_award_period = Plink::UsersAwardPeriodRecord.where('userID = ? AND offers_virtual_currency_id = ?', user_without_expired_offer.id, valid_offer_offers_virtual_currency.id).first

    expiring_users_award_period.end_date.should > Date.current.midnight
    another_expiring_users_award_period.end_date.should > Date.current.midnight
    other_users_expiring_users_award_period.end_date.should > Date.current.midnight
    other_users_non_expiring_users_award_period.end_date.should > Date.current.midnight
    non_expiring_users_award_period.end_date.should > Date.current.midnight

    subject.invoke

    expiring_users_award_period.reload.end_date.should == Date.current.midnight
    another_expiring_users_award_period.reload.end_date.should == Date.current.midnight
    other_users_expiring_users_award_period.reload.end_date.should == Date.current.midnight
    other_users_non_expiring_users_award_period.reload.end_date.should > Date.current.midnight
    non_expiring_users_award_period.reload.end_date.should > Date.current.midnight
  end
end

