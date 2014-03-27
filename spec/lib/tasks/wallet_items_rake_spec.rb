require 'spec_helper'

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

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end
    it 'does not unlock wallet items for users without qualifying transactions' do
      no_qualified_transactions_wallet.locked_wallet_items.size.should == 1
      no_qualified_transactions_wallet.open_wallet_items.should be_empty

      capture_stdout { subject.invoke }

      no_qualified_transactions_wallet.reload
      no_qualified_transactions_wallet.locked_wallet_items.size.should == 1
      no_qualified_transactions_wallet.open_wallet_items.should be_empty
    end

    it 'unlocks wallet items for eligible users' do
      pending_qualified_transactions_wallet.open_wallet_items.size.should == 1
      pending_qualified_transactions_wallet.locked_wallet_items.size.should == 1

      capture_stdout { subject.invoke }

      pending_qualified_transactions_wallet.reload
      pending_qualified_transactions_wallet.open_wallet_items.size.should == 2
      pending_qualified_transactions_wallet.locked_wallet_items.size.should == 0
    end

    it 'does not unlock wallet items for users who had previously unlocked' do
      previously_unlocked_wallet.open_wallet_items.size.should == 1
      previously_unlocked_wallet.locked_wallet_items.should be_empty

      capture_stdout { subject.invoke }

      previously_unlocked_wallet.reload
      previously_unlocked_wallet.open_wallet_items.size.should == 1
      previously_unlocked_wallet.locked_wallet_items.should be_empty
    end
  end

  context 'when there are exceptions' do
    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::WalletItemUnlockingService.stub(:unlock_transaction_items_for_eligible_users).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
          exception.should be_a(RuntimeError)
          message.should =~ /unlock_transaction_wallet_item/
      end

      subject.invoke
    end
  end
end

describe 'wallet_items:unlock_transaction_promotion_wallet_items' do
  include_context 'rake'

  let(:good_post_date) { Time.parse('2013-10-26') }
  let(:too_early_post_date) { Time.parse('2013-10-14') }
  let(:too_late_post_date) { Time.parse('2013-10-31') }
  let!(:primary_virtual_currency) { create_virtual_currency(subdomain: 'www') }
  let!(:swagbucks_virtual_currency) { create_virtual_currency(subdomain: 'swagbucks') }

  let!(:eligible_user) do
    user = create_user(email: 'von_damme@example.com', first_name: 'Jean-Claude')
    create_wallet(user_id: user.id)
    create_intuit_transaction(user_id: user.id, post_date: good_post_date)
    user
  end

  let!(:second_eligible_user) do
    user = create_user(email: 'rambo@example.com', first_name: 'John')
    create_wallet(user_id: user.id)
    create_intuit_transaction(user_id: user.id, post_date: good_post_date)
    user
  end

  let!(:no_transaction_user) do
    user = create_user(email: 'machete@example.com')
    create_wallet(user_id: user.id)
    user
  end

  let!(:wrong_vc_user) do
    user = create_user(email: 'machete_dos@example.com')
    user.primary_virtual_currency = swagbucks_virtual_currency
    user.save
    create_wallet(user_id: user.id)
    create_intuit_transaction(user_id: user.id, post_date: good_post_date)
    user
  end

  let!(:previously_unlocked_user) do
    user = create_user(email: 'dolph@example.com')
    wallet = create_wallet(user_id: user.id)
    create_open_wallet_item(wallet_id: wallet.id, unlock_reason: 'promotion')
    create_intuit_transaction(user_id: user.id, post_date: good_post_date)
    user
  end

  let!(:ineligible_transaction_user) do
    user = create_user(email: 'willis@example.com')
    create_wallet(user_id: user.id)
    create_intuit_transaction(user_id: user.id, post_date: too_early_post_date)
    create_intuit_transaction(user_id: user.id, post_date: too_late_post_date)
    user
  end

  let(:valid_wallet_item_params) {
    {
      wallet_slot_id: 1,
      wallet_slot_type_id: 1,
      unlock_reason: 'promotion'
    }
  }

  it 'unlocks slots for the users that are eligible' do
    eligible_user.open_wallet_items.length.should == 0
    second_eligible_user.open_wallet_items.length.should == 0
    no_transaction_user.open_wallet_items.length.should == 0
    wrong_vc_user.open_wallet_items.length.should == 0
    previously_unlocked_user.open_wallet_items.length.should == 1
    ineligible_transaction_user.open_wallet_items.length.should == 0

    capture_stdout { subject.invoke }

    eligible_user.reload.open_wallet_items.length.should == 1
    second_eligible_user.reload.open_wallet_items.length.should == 1
    no_transaction_user.reload.open_wallet_items.length.should == 0
    wrong_vc_user.reload.open_wallet_items.length.should == 0
    previously_unlocked_user.reload.open_wallet_items.length.should == 1
    ineligible_transaction_user.reload.open_wallet_items.length.should == 0
  end

  it 'sets the reason for the unlocked slot as promotion' do
    eligible_user.open_wallet_items.map(&:unlock_reason).should_not include('promotion')
    second_eligible_user.open_wallet_items.map(&:unlock_reason).should_not include('promotion')

    capture_stdout { subject.invoke }

    eligible_user.reload.open_wallet_items.map(&:unlock_reason).should include('promotion')
    second_eligible_user.reload.open_wallet_items.map(&:unlock_reason).should include('promotion')
  end

  it 'creates an open wallet item for eligible users' do
    Plink::WalletItemService.should_receive(:create_open_wallet_item)
      .with(eligible_user.wallet.id, 'promotion')
    Plink::WalletItemService.should_receive(:create_open_wallet_item)
      .with(second_eligible_user.wallet.id, 'promotion')

    capture_stdout { subject.invoke }
  end

  it 'emails eligible users letting them know they have a newly-opened slot' do
    delay_double = double(unlock_promotional_wallet_item_email: true)

    Plink::UserAutoLoginRecord.should_receive(:create).twice.and_return(double(user_token:'asd'))

    PromotionalWalletItemMailer.should_receive(:delay).twice.and_return(delay_double)

    delay_double.should_receive(:unlock_promotional_wallet_item_email).with(
      first_name: 'Jean-Claude',
      email: 'von_damme@example.com',
      user_token: 'asd'
    )

    delay_double.should_receive(:unlock_promotional_wallet_item_email).with(
      first_name: 'John',
      email: 'rambo@example.com',
      user_token: 'asd'
    )

    capture_stdout { subject.invoke }
  end
end

describe 'wallet_items:unlock_app_install_promotion_wallet_items' do
  include_context 'rake'

  let!(:primary_virtual_currency) { create_virtual_currency(subdomain: 'www') }

  let(:in_period_install_date) { Time.parse('2013-11-24') }
  let(:before_period_install_date) { Time.parse('2012-10-14') }
  let(:after_period_install_date) { Time.parse('2013-11-25') }

  let(:in_period_user) { create_user(first_name: 'beefy', email: 'in@example.com') }
  let(:before_period_user) { create_user(first_name: 'tacos', email: 'before@example.com') }
  let(:after_period_user) { create_user(email: 'after@example.com') }
  let!(:previously_unlocked_user) do
    user = create_user(email: 'dolph@example.com')
    wallet = create_wallet(user_id: user.id)
    create_open_wallet_item(wallet_id: wallet.id, unlock_reason: 'app_install_promotion')
    user
  end

  before do
    [in_period_user, before_period_user, after_period_user].each do |user|
      create_wallet(user_id: user.id)
    end

    in_period_token = create_authentication_token(user_id: in_period_user.id)
    in_period_token.update_attribute('created_at', in_period_install_date)

    before_period_token = create_authentication_token(user_id: before_period_user.id)
    before_period_token.update_attribute('created_at', before_period_install_date)

    after_period_token = create_authentication_token(user_id: after_period_user.id)
    after_period_token.update_attribute('created_at', after_period_install_date)
  end

  it 'unlocks slots for the users that are eligible' do
    in_period_user.open_wallet_items.length.should == 0
    before_period_user.open_wallet_items.length.should == 0
    after_period_user.open_wallet_items.length.should == 0
    previously_unlocked_user.open_wallet_items.length.should == 1

    capture_stdout { subject.invoke }

    in_period_user.reload.open_wallet_items.length.should == 1
    before_period_user.reload.open_wallet_items.length.should == 1
    after_period_user.reload.open_wallet_items.length.should == 0
    previously_unlocked_user.reload.open_wallet_items.length.should == 1
  end

  it 'sets the reason for the unlocked slot as app_install_promotion' do
    in_period_user.open_wallet_items.map(&:unlock_reason).should_not include('app_install_promotion')
    before_period_user.open_wallet_items.map(&:unlock_reason).should_not include('app_install_promotion')

    capture_stdout { subject.invoke }

    in_period_user.reload.open_wallet_items.map(&:unlock_reason).should include('app_install_promotion')
    before_period_user.reload.open_wallet_items.map(&:unlock_reason).should include('app_install_promotion')
  end

  it 'creates an open wallet item for eligible users' do
    Plink::WalletItemService.should_receive(:create_open_wallet_item)
      .with(in_period_user.wallet.id, 'app_install_promotion')
    Plink::WalletItemService.should_receive(:create_open_wallet_item)
      .with(before_period_user.wallet.id, 'app_install_promotion')

    capture_stdout { subject.invoke }
  end

  it 'emails eligible users letting them know they have a newly-opened slot' do
    delay_double = double(unlock_promotional_wallet_item_email: true)

    Plink::UserAutoLoginRecord.should_receive(:create).twice.and_return(double(user_token:'asd'))

    PromotionalWalletItemMailer.should_receive(:delay).twice.and_return(delay_double)

    delay_double.should_receive(:unlock_promotional_wallet_item_email).with(
      first_name: 'beefy',
      email: 'in@example.com',
      user_token: 'asd'
    )

    delay_double.should_receive(:unlock_promotional_wallet_item_email).with(
      first_name: 'tacos',
      email: 'before@example.com',
      user_token: 'asd'
    )

    capture_stdout { subject.invoke }
  end
end

describe "wallet_items:remove_expired_offers", skip_in_build: true do
  include_context "rake"

  let(:virtual_currency) { create_virtual_currency }
  let(:advertiser) { create_advertiser(advertiser_name: 'bk') }

  let(:valid_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:valid_offer) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: Date.current,
      offers_virtual_currencies: [valid_offer_offers_virtual_currency]
    )
  }
  let!(:valid_offer_tier_one) { create_tier(offers_virtual_currency_id: valid_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }
  let!(:valid_offer_tier_two) { create_tier(offers_virtual_currency_id: valid_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }

  let(:expired_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:expired_offer) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: Date.yesterday.midnight,
      offers_virtual_currencies: [expired_offer_offers_virtual_currency]
    )
  }
  let!(:expired_offer_tier_one) { create_tier(offers_virtual_currency_id: expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }
  let!(:expired_offer_tier_two) { create_tier(offers_virtual_currency_id: expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }

  let(:another_expired_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:another_expired_offer) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: Date.yesterday.midnight,
      offers_virtual_currencies: [another_expired_offer_offers_virtual_currency]
    )
  }
  let!(:another_expired_offer_tier_one) { create_tier(offers_virtual_currency_id: another_expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }
  let!(:another_expired_offer_tier_two) { create_tier(offers_virtual_currency_id: another_expired_offer.offers_virtual_currencies.first.id, end_date: '2999-12-31') }

  let(:non_expired_offer_with_mixed_tiers_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:non_expired_offer_with_mixed_tiers) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: Date.yesterday.midnight,
      offers_virtual_currencies: [non_expired_offer_with_mixed_tiers_offers_virtual_currency]
    )
  }
  let!(:non_expired_offer_expired_tier) { create_tier(offers_virtual_currency_id: non_expired_offer_with_mixed_tiers.offers_virtual_currencies.first.id, end_date: '2001-01-01', is_active: false) }
  let!(:non_expired_offer_non_expired_tier) { create_tier(offers_virtual_currency_id: non_expired_offer_with_mixed_tiers.offers_virtual_currencies.first.id, end_date: '2999-12-31') }

  let(:user_with_expired_offer) { create_user(first_name: 'kramer', email: 'foo@example.com') }
  let(:other_user_with_expired_offer) { create_user(first_name: 'jerry',email: 'ichabod@example.com') }
  let(:user_without_expired_offer) { create_user(first_name: 'george',email: 'loser@example.com') }
  let(:user_with_expired_tier) { create_user(first_name: 'elaine',email: 'frizzy@example.com') }

  before do
    [user_with_expired_offer, other_user_with_expired_offer, user_without_expired_offer, user_with_expired_tier].each do |user|
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

    Plink::AddOfferToWalletService.new(user: user_with_expired_tier, offer: non_expired_offer_with_mixed_tiers).add_offer
  end

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'removes offers that have expired from every wallet' do
      Plink::RemoveOfferFromWalletService.should_receive(:new).exactly(4).times.and_call_original

      capture_stdout { subject.invoke }

      grouped_items = user_with_expired_offer.wallet.wallet_item_records.map(&:type).group_by { |elem| elem }
      grouped_items['Plink::OpenWalletItemRecord'].length.should == 2
      grouped_items['Plink::PopulatedWalletItemRecord'].should be_nil

      grouped_items = other_user_with_expired_offer.wallet.wallet_item_records.map(&:type).group_by { |elem| elem }
      grouped_items['Plink::OpenWalletItemRecord'].length.should == 1
      grouped_items['Plink::PopulatedWalletItemRecord'].length.should == 1

      grouped_items = user_without_expired_offer.wallet.wallet_item_records.map(&:type).group_by { |elem| elem }
      grouped_items['Plink::OpenWalletItemRecord'].length.should == 1
      grouped_items['Plink::PopulatedWalletItemRecord'].length.should == 1

      grouped_items = user_with_expired_tier.wallet.wallet_item_records.map(&:type).group_by { |elem| elem }
      grouped_items['Plink::OpenWalletItemRecord'].length.should == 2
      grouped_items['Plink::PopulatedWalletItemRecord'].should be_nil
    end

    it 'emails the users that have the expired offer in their wallet' do
      delay = double(offer_removed_email: true)

      Plink::UserAutoLoginRecord.should_receive(:create).exactly(4).times.
        and_return(double(user_token:'asd'))

      OfferExpirationMailer.should_receive(:delay).exactly(4).times.
        with(run_at: Time.zone.parse("#{Date.current} 10:30:00")).
        and_return(delay)

      delay.should_receive(:offer_removed_email) do |args|
        args.length.should == 4
        ['jerry', 'kramer', 'george', 'elaine'].should include(args[:first_name])
        ['foo@example.com', 'ichabod@example.com', 'loser@example.com', 'frizzy@example.com'].should include(args[:email])
        args[:advertiser_name].should == 'bk'
        args[:user_token].should == 'asd'
      end

      capture_stdout { subject.invoke }
    end

    it 'end dates all tiers associated to the offer through its offers virtual currencies' do
      expired_offer_tier_one.end_date.should_not == expired_offer.end_date
      expired_offer_tier_two.end_date.should_not == expired_offer.end_date
      another_expired_offer_tier_one.end_date.should_not == another_expired_offer.end_date
      another_expired_offer_tier_two.end_date.should_not == another_expired_offer.end_date
      valid_offer_tier_one.end_date.should_not == valid_offer.end_date
      valid_offer_tier_two.end_date.should_not == valid_offer.end_date

      capture_stdout { subject.invoke }

      expired_offer_tier_one.reload.end_date.should == expired_offer.end_date
      expired_offer_tier_two.reload.end_date.should == expired_offer.end_date
      another_expired_offer_tier_one.reload.end_date.should == another_expired_offer.end_date
      another_expired_offer_tier_two.reload.end_date.should == another_expired_offer.end_date
      valid_offer_tier_one.end_date.should_not == valid_offer.end_date
      valid_offer_tier_two.end_date.should_not == valid_offer.end_date
    end

    it 'does not change the end date of inactive tiers' do
      non_expired_offer_expired_tier.end_date.should == Time.zone.parse('2001-01-01')

      capture_stdout { subject.invoke }

      non_expired_offer_expired_tier.reload.end_date.should == Time.zone.parse('2001-01-01')
      non_expired_offer_non_expired_tier.reload.end_date.should == non_expired_offer_with_mixed_tiers.end_date
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

      capture_stdout { subject.invoke }

      expiring_users_award_period.reload.end_date.should == Date.current.midnight
      another_expiring_users_award_period.reload.end_date.should == Date.current.midnight
      other_users_expiring_users_award_period.reload.end_date.should == Date.current.midnight
      other_users_non_expiring_users_award_period.reload.end_date.should > Date.current.midnight
      non_expiring_users_award_period.reload.end_date.should > Date.current.midnight
    end
  end

  context 'when there are exceptions' do
    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      AutoLoginService.stub(:generate_token).and_raise

      ::Exceptional::Catcher.should_receive(:handle).exactly(4).times do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /remove_expired_offers/
      end

      subject.invoke
    end

    it 'includes the offers_virtual_currencies.id in the record-level exception text' do
      AutoLoginService.stub(:generate_token).and_raise

      ::Exceptional::Catcher.should_receive(:handle).exactly(4).times do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /offers_virtual_currencies\.id = \d+/
      end

      subject.invoke
    end

    it 'includes the user.id in the record-level exception text' do
      AutoLoginService.stub(:generate_token).and_raise

      ::Exceptional::Catcher.should_receive(:handle).exactly(4).times do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /user\.id = \d+/
      end

      subject.invoke
    end

    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::OfferRecord.stub(:where).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /remove_expired_offers/
      end

      subject.invoke
    end

    it 'does not include user.id in task-level exceptions' do
      Plink::OfferRecord.stub(:where).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id =/)

      subject.invoke
    end

    it 'does not include offers_virtual_currencies.id in task-level exceptions' do
      Plink::OfferRecord.stub(:where).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/offers_virtual_currencies\.id =/)

      subject.invoke
    end
  end
end

describe "wallet_items:notify_users_of_expiring_offers" do
  include_context "rake"

  let(:virtual_currency) { create_virtual_currency }
  let(:advertiser) { create_advertiser(advertiser_name: 'bk') }

  let(:valid_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:valid_offer) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: 4.days.from_now,
      offers_virtual_currencies: [valid_offer_offers_virtual_currency]
    )
  }

  let(:expiring_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:expiring_offer) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: 3.days.from_now.to_date,
      send_expiring_soon_reminder: true,
      offers_virtual_currencies: [expiring_offer_offers_virtual_currency]
    )
  }

  let(:expiring_offer_without_notice_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:expiring_offer_without_notice) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: 3.days.from_now,
      send_expiring_soon_reminder: false,
      offers_virtual_currencies: [expiring_offer_without_notice_offers_virtual_currency]
    )
  }

  let(:user_with_expiring_offer) { create_user(first_name: 'kramer', email: 'foo@example.com') }
  let(:user_with_expiring_offer_without_notice) { create_user(first_name: 'jerry',email: 'jerry@example.com') }
  let(:user_without_expiring_offer) { create_user(first_name: 'george',email: 'loser@example.com') }

  before do
    [user_with_expiring_offer, user_with_expiring_offer_without_notice, user_without_expiring_offer].each do |user|
      create_wallet(
        user_id: user.id,
        wallet_item_records: [new_open_wallet_item, new_open_wallet_item]
      )
    end

    Plink::AddOfferToWalletService.new(user: user_with_expiring_offer, offer: expiring_offer).add_offer
    Plink::AddOfferToWalletService.new(user: user_with_expiring_offer_without_notice, offer: expiring_offer_without_notice).add_offer
    Plink::AddOfferToWalletService.new(user: user_without_expiring_offer, offer: valid_offer).add_offer
  end

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'sends an email to everyone with an offer in their wallet that expires in 3 days as a delayed job' do
      delay_double = double(offer_expiring_soon_email: true)

      Plink::UserAutoLoginRecord.should_receive(:create).and_return(double(user_token:'asd'))

      OfferExpirationMailer.should_receive(:delay).and_return(delay_double)

      delay_double.should_receive(:offer_expiring_soon_email).with(
        first_name: 'kramer',
        email:  'foo@example.com',
        end_date: instance_of(ActiveSupport::TimeWithZone),
        advertiser_name: 'bk',
        user_token: 'asd'
      )

      capture_stdout { subject.invoke }
    end

    it 'sends an email to everyone with an offer in their wallet that expires in 3 days' do
      capture_stdout { subject.invoke }

      ActionMailer::Base.deliveries.should_not be_empty
      ActionMailer::Base.deliveries.first.to.should == [user_with_expiring_offer.email]
    end
  end

  context 'when there are exceptions' do
    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      AutoLoginService.stub(:generate_token).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /notify_users_of_expiring_offers/
      end

      subject.invoke
    end

    it 'includes the user.id in the record-level exception text' do
      AutoLoginService.stub(:generate_token).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /user\.id = \d+/
      end

      subject.invoke
    end

    it 'includes the offer.id in the record-level exception text' do
      AutoLoginService.stub(:generate_token).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /offer\.id = \d+/
      end

      subject.invoke
    end

    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::OfferRecord.stub(:where).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /notify_users_of_expiring_offers/
      end

      subject.invoke
    end

    it 'does not include user.id in the task-level exception text' do
      Plink::OfferRecord.stub(:where).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id = \d+/)

      subject.invoke
    end

    it 'does not include offer.id in the task-level exception text' do
      Plink::OfferRecord.stub(:where).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/offer\.id = \d+/)

      subject.invoke
    end
  end
end
