namespace :non_qualifying_transactions do
  desc 'Sends out emails to plink point users who have made an out of wallet transaction that is above the minimum'
  task send_offer_add_bonus_emails: :environment do
    virtual_currency_presenter = default_virtual_currency_presenter

    transactions_eligible_for_bonus.each do |transaction_eligible_for_bonus|
      user_record = transaction_eligible_for_bonus.user_record

      if user_is_eligible(user_record, transaction_eligible_for_bonus.offers_virtual_currency_id)
        user_eligible_for_offer_add_bonus = Plink::UserEligibleForOfferAddBonusRecord.new(
          offers_virtual_currency_id: transaction_eligible_for_bonus.offers_virtual_currency_id,
          user_id: user_record.id
        )

        if user_eligible_for_offer_add_bonus.save
          offer = Plink::OfferService.new.get_by_id_and_virtual_currency_id(
            transaction_eligible_for_bonus.offer_id, virtual_currency_presenter.id
          )

          BonusNotificationMailer.delay.out_of_wallet_transaction_email({
            first_name: user_record.first_name,
            email: user_record.email,
            advertiser_name: offer.name,
            max_plink_points: virtual_currency_presenter.amount_in_currency(offer.max_dollar_award_amount),
            user_token: AutoLoginService.generate_token(user_record.id)
          })
        end
      end

      transaction_eligible_for_bonus.update_attribute('processed', true)
    end
  end

private

  def default_virtual_currency_presenter
    VirtualCurrencyPresenter.new({virtual_currency: plink_points})
  end

  def plink_points
    Plink::VirtualCurrency.default
  end

  def transactions_eligible_for_bonus
    Plink::TransactionEligibleForBonusRecord
      .where('processed = ?', false)
      .includes(:user_record)
  end

  def user_is_eligible(user_record, offers_virtual_currency_id)
    user_record.is_subscribed \
      && !user_record.wallet.has_offers_virtual_currency(offers_virtual_currency_id) \
      && user_record.primary_virtual_currency == plink_points
  end
end

