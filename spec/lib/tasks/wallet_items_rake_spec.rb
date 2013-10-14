require 'spec_helper'
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

  let(:user_with_expired_offer) { create_user(first_name: 'kramer', email: 'foo@example.com') }
  let(:other_user_with_expired_offer) { create_user(first_name: 'jerry',email: 'ichabod@example.com') }
  let(:user_without_expired_offer) { create_user(first_name: 'george',email: 'loser@example.com') }

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

  it 'emails the users that have the expired offer in their wallet' do
    delay_double = double(offer_removed_email: true)

    Plink::UserAutoLoginRecord.should_receive(:create)
      .exactly(3).times
      .and_return(double(user_token:'asd'))

    OfferExpirationMailer.should_receive(:delay)
      .exactly(3).times
      .with(run_at: Time.zone.parse("#{Date.current} 10:30:00"))
      .and_return(delay_double)

    delay_double.should_receive(:offer_removed_email) do |args|
      args.length.should == 4
      ['jerry', 'kramer', 'george'].should include(args[:first_name])
      ['foo@example.com', 'ichabod@example.com', 'loser@example.com'].should include(args[:email])
      args[:advertiser_name].should == 'bk'
      args[:user_token].should == 'asd'
    end

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

describe "wallet_items:notify_users_of_expiring_offers" do
  include_context "rake"

  let(:virtual_currency) { create_virtual_currency }
  let(:advertiser) { create_advertiser(advertiser_name: 'bk') }

  let(:valid_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:valid_offer) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: 8.days.from_now,
      offers_virtual_currencies: [valid_offer_offers_virtual_currency]
    )
  }


  let(:expiring_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:expiring_offer) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: 7.days.from_now.to_date,
      send_expiring_soon_reminder: true,
      offers_virtual_currencies: [expiring_offer_offers_virtual_currency]
    )
  }

  let(:expiring_offer_without_notice_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:expiring_offer_without_notice) {
    create_offer(
      advertiser_id: advertiser.id,
      end_date: 7.days.from_now,
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

  it 'sends an email to everyone with an offer in their wallet that expires in 7 days as a delayed job' do
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

    subject.invoke

  end
  it 'sends an email to everyone with an offer in their wallet that expires in 7 days' do
    subject.invoke

    ActionMailer::Base.deliveries.should_not be_empty
    ActionMailer::Base.deliveries.first.to.should == [user_with_expiring_offer.email]
  end
end
