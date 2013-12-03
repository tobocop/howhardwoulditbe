namespace :non_qualifying_transactions do
  desc 'Sends out emails to plink point users who have made an out of wallet transaction that is above the minimum'
  task send_offer_add_bonus_emails: :environment do
    virtual_currency_presenter = default_virtual_currency_presenter

    users_eligible_for_bonus.each do |user_eligible_for_bonus|
      user_record = Plink::UserRecord.find_by_id(user_eligible_for_bonus.user_id)

      if user_is_eligible(user_record, user_eligible_for_bonus.offers_virtual_currency_id)
        user_eligible_for_offer_add_bonus = Plink::UserEligibleForOfferAddBonusRecord.new(
          is_awarded: false,
          offers_virtual_currency_id: user_eligible_for_bonus.offers_virtual_currency_id,
          user_id: user_record.id
        )

        offer = Plink::OfferService.new.get_by_id_and_virtual_currency_id(
          user_eligible_for_bonus.offer_id, virtual_currency_presenter.id
        )

        next if offer.end_date.to_date < 9.days.from_now.to_date

        mail_params = {
          first_name: user_record.first_name,
          email: user_record.email,
          advertiser_name: offer.name,
          max_plink_points: virtual_currency_presenter.amount_in_currency(offer.max_dollar_award_amount),
          user_token: AutoLoginService.generate_token(user_record.id)
        }

        if user_eligible_for_offer_add_bonus.save
          BonusNotificationMailer.delay.out_of_wallet_transaction_email(mail_params)
        else
          BonusNotificationMailer.delay.out_of_wallet_transaction_reminder_email(mail_params)
        end
      end

      transactions_processed(user_eligible_for_bonus)
    end
  end

private

  def default_virtual_currency_presenter
    VirtualCurrencyPresenter.new({virtual_currency: plink_points})
  end

  def plink_points
    Plink::VirtualCurrency.default
  end

  def users_eligible_for_bonus
    Plink::TransactionEligibleForBonusRecord
      .select('user_id, offer_id, offers_virtual_currency_id')
      .where('processed = ?', false)
      .group('user_id, offer_id, offers_virtual_currency_id')
  end

  def transactions_processed(user_eligible_for_bonus)
    Plink::TransactionEligibleForBonusRecord
      .where('user_id = ?', user_eligible_for_bonus.user_id)
      .where('offer_id = ?', user_eligible_for_bonus.offer_id)
      .where('offers_virtual_currency_id = ?', user_eligible_for_bonus.offers_virtual_currency_id)
      .update_all(processed: true)
  end

  def user_is_eligible(user_record, offers_virtual_currency_id)
    user_record.is_subscribed \
      && !user_record.wallet.has_offers_virtual_currency(offers_virtual_currency_id) \
      && user_record.primary_virtual_currency == plink_points
  end
end

