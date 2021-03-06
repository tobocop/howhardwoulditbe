require 'spec_helper'

describe 'non_qualifying_transactions:send_offer_add_bonus_emails' do
  include_context 'rake'
  let!(:virtual_currency) { create_virtual_currency(subdomain: 'www') }
  let!(:user) {
    create_user(
      email: 'seinfeld@newyork.com',
      first_name: 'jerry',
      is_subscribed: true
    )
  }
  let!(:wallet) { create_wallet(user_id: user.id) }

  let(:gap) { create_advertiser(advertiser_name: 'gap') }
  let(:first_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:first_offer) {
    create_offer(
      advertiser_id: gap.id,
      end_date: 9.days.from_now,
      offers_virtual_currencies: [first_offer_offers_virtual_currency]
    )
  }
  let!(:first_offer_tier_one) { create_tier(dollar_award_amount: 5.00, offers_virtual_currency_id: first_offer_offers_virtual_currency.id) }
  let!(:first_offer_tier_two) { create_tier(dollar_award_amount: 15.00, offers_virtual_currency_id: first_offer_offers_virtual_currency.id) }

  let(:old_navy) { create_advertiser(advertiser_name: 'old navy') }
  let(:second_offer_offers_virtual_currency) { create_offers_virtual_currency(virtual_currency_id: virtual_currency.id) }
  let!(:second_offer) {
    create_offer(
      advertiser_id: old_navy.id,
      offers_virtual_currencies: [second_offer_offers_virtual_currency]
    )
  }
  let!(:second_offer_tier_one) { create_tier(dollar_award_amount: 5.00, offers_virtual_currency_id: second_offer_offers_virtual_currency.id) }
  let!(:second_offer_tier_two) { create_tier(dollar_award_amount: 20.00, offers_virtual_currency_id: second_offer_offers_virtual_currency.id) }

  let!(:transaction_eligible_for_bonus) {
    create_transaction_eligible_for_bonus(
      intuit_transaction_id: 1,
      offer_id: first_offer.id,
      offers_virtual_currency_id: first_offer_offers_virtual_currency.id,
      processed: false,
      user_id: user.id
    )
  }

  let(:mailer) { double(out_of_wallet_transaction_email: true) }

  before do
    create_open_wallet_item(wallet_id: wallet.id)
    BonusNotificationMailer.stub(delay: mailer)
  end

  context 'when there are no exceptions' do
    before do
      ::Exceptional::Catcher.should_not_receive(:handle)
    end

    it 'emails plink point users who have made an out of wallet transaction that is above the minimum once per offer' do
      create_transaction_eligible_for_bonus(
        intuit_transaction_id: 1,
        offer_id: second_offer.id,
        offers_virtual_currency_id: second_offer_offers_virtual_currency.id,
        processed: false,
        user_id: user.id
      )

      AutoLoginService.should_receive(:generate_token)
        .with(user.id)
        .exactly(2).times
        .and_return('my_token')
      mailer.should_receive(:out_of_wallet_transaction_email)
        .with(
          first_name: 'jerry',
          email: 'seinfeld@newyork.com',
          advertiser_name: 'gap',
          max_plink_points: '1500',
          user_token: 'my_token'
        )
      mailer.should_receive(:out_of_wallet_transaction_email)
        .with(
          first_name: 'jerry',
          email: 'seinfeld@newyork.com',
          advertiser_name: 'old navy',
          max_plink_points: '2000',
          user_token: 'my_token'
        )

      mailer.should_not_receive(:out_of_wallet_transaction_reminder_email)

      subject.invoke
    end

    it 'updates records as processed' do
      second_transaction = create_transaction_eligible_for_bonus(
        intuit_transaction_id: 1,
        offer_id: first_offer.id,
        offers_virtual_currency_id: first_offer_offers_virtual_currency.id,
        processed: false,
        user_id: user.id
      )

      subject.invoke

      transaction_eligible_for_bonus.reload.processed.should be_true
      second_transaction.reload.processed.should be_true
    end

    it 'inserts a record indicating the user is eligible for a bonus' do
      subject.invoke

      eligible_users = Plink::UserEligibleForOfferAddBonusRecord.where(
        is_awarded: false,
        user_id:user.id,
        offers_virtual_currency_id: first_offer_offers_virtual_currency.id
      )
      eligible_users.length.should == 1
    end

    it 'only sends emails to subscribed members' do
      user.update_attribute(:is_subscribed, false)
      mailer.should_not_receive(:out_of_wallet_transaction_email)

      subject.invoke
    end

    it 'only sends emails to users who do not have the offer in their wallet ' do
      Plink::AddOfferToWalletService.new(user: user, offer: first_offer).add_offer
      mailer.should_not_receive(:out_of_wallet_transaction_email)

      subject.invoke
    end

    it 'only sends one email to a user even if there are multiple non qualifying transactions' do
      create_transaction_eligible_for_bonus(
        intuit_transaction_id: 1,
        offer_id: first_offer.id,
        offers_virtual_currency_id: first_offer_offers_virtual_currency.id,
        processed: false,
        user_id: user.id
      )

      mailer.should_receive(:out_of_wallet_transaction_email).once

      subject.invoke
    end

    it 'sends a reminder emails to the user if the user is not eligible for the bonus' do
      Plink::UserEligibleForOfferAddBonusRecord.stub(:new).and_return(double(save: false))
      mailer.should_not_receive(:out_of_wallet_transaction_email)

      AutoLoginService.should_receive(:generate_token)
        .with(user.id)
        .and_return('my_token')
      mailer.should_receive(:out_of_wallet_transaction_reminder_email)
        .with(
          first_name: 'jerry',
          email: 'seinfeld@newyork.com',
          advertiser_name: 'gap',
          max_plink_points: '1500',
          user_token: 'my_token'
        )

      subject.invoke
    end

    it 'only sends emails to users who have transactions eligible to be processed' do
      transaction_eligible_for_bonus.update_attribute('processed', true)
      mailer.should_not_receive(:out_of_wallet_transaction_email)

      subject.invoke
    end

    it 'only send emails to plink point members' do
      swagbucks = create_virtual_currency(subdomain: 'swagbucks')
      user.primary_virtual_currency = swagbucks
      user.save
      mailer.should_not_receive(:out_of_wallet_transaction_email)

      subject.invoke
    end

    it 'only send emails for offers that are expiring in more then 8 days' do
      first_offer.update_attribute('end_date', 8.days.from_now)
      mailer.should_not_receive(:out_of_wallet_transaction_email)

      subject.invoke
    end
  end

  context 'when there are exceptions' do
    it 'logs record-level exceptions to Exceptional with the Rake task name' do
      Plink::UserRecord.stub(:find_by_id).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /send_offer_add_bonus_emails/
      end

      subject.invoke
    end

    it 'includes the user.id in the record-level exception text' do
      Plink::UserRecord.stub(:find_by_id).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /user\.id = \d+/
      end

      subject.invoke
    end

    it 'includes the offer.id in the record-level exception text' do
      Plink::UserRecord.stub(:find_by_id).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /offer\.id = \d+/
      end

      subject.invoke
    end

    it 'logs Rake task-level failures to Exceptional with the Rake task name' do
      Plink::TransactionEligibleForBonusRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_receive(:handle) do |exception, message|
        exception.should be_a(RuntimeError)
        message.should =~ /send_offer_add_bonus_emails/
      end

      subject.invoke
    end

    it 'does not include user.id in the task-level exception text' do
      Plink::TransactionEligibleForBonusRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/user\.id =/)

      subject.invoke
    end

    it 'does not include offer.id in the task-level exception text' do
      Plink::TransactionEligibleForBonusRecord.stub(:select).and_raise

      ::Exceptional::Catcher.should_not_receive(:handle).with(/offer\.id =/)

      subject.invoke
    end
  end
end

