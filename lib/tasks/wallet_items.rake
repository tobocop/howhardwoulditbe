namespace :wallet_items do
  desc "Unlock wallet items for users who have a qualifying transaction"
  task unlock_transaction_wallet_item: :environment do
    Plink::WalletItemUnlockingService.unlock_transaction_items_for_eligible_users
  end

  desc 'Unlocks wallet items during the promotional period'
  task unlock_transaction_promotion_wallet_items: :environment do
    users_eligible_for_transaction_promotion_wallet_item.each do |wallet_record|
      Plink::WalletItemService.create_open_wallet_item(wallet_record.id, Plink::WalletRecord.transaction_promotion_unlock_reason)

      user_token = AutoLoginService.generate_token(wallet_record.user_id)
      PromotionalWalletItemMailer.delay.unlock_promotional_wallet_item_email(
        first_name: wallet_record.attributes['firstName'],
        email: wallet_record.attributes['emailAddress'],
        user_token: user_token
      )
    end
  end

  desc 'Removes all expired offers from users wallets and end dates their associated tiers'
  task remove_expired_offers: :environment do
    expired_offers = offers_with_end_date_between_given_dates(7.days.ago.to_date, Date.current)

    ten_thirty = Time.zone.parse("#{Date.current} 10:30:00")

    expired_offers.each do |expired_offer|
      expired_offer.active_offers_virtual_currencies.each do |offers_virtual_currency|

        offers_virtual_currency.tiers.each do |tier_record|
          tier_record.update_attributes(:end_date => expired_offer.end_date)
        end

        user_with_offer_in_wallet(offers_virtual_currency.id).each do |user_record|
          Plink::RemoveOfferFromWalletService.new(user_record.id, expired_offer.id).remove_offer

          user_token = AutoLoginService.generate_token(user_record.id)
          OfferExpirationMailer.delay(run_at: ten_thirty)
            .offer_removed_email(
              first_name: user_record.first_name,
              email:  user_record.email,
              advertiser_name: expired_offer.advertiser.advertiser_name,
              user_token: user_token
            )
        end
      end
    end
  end

  desc 'Notifies users 7 days before an offer in their wallet is going to expire'
  task notify_users_of_expiring_offers: :environment do
    offers_expiring_in_seven_days = offers_with_end_date_between_given_dates(7.days.from_now.to_date, 8.days.from_now.to_date)

    offers_expiring_in_seven_days.each do |expiring_offer|
      next unless expiring_offer.send_expiring_soon_reminder
      expiring_offer.active_offers_virtual_currencies.each do |offers_virtual_currency|
        user_with_offer_in_wallet(offers_virtual_currency.id).each do |user_record|
          user_token = AutoLoginService.generate_token(user_record.id)
          OfferExpirationMailer.delay
            .offer_expiring_soon_email(
              first_name: user_record.first_name,
              email:  user_record.email,
              end_date: expiring_offer.end_date,
              advertiser_name: expiring_offer.advertiser.advertiser_name,
              user_token: user_token
            )
        end
      end
    end
  end

private

  def users_eligible_for_transaction_promotion_wallet_item
    relation = Plink::WalletRecord
      .wallets_without_item_unlocked(Plink::WalletRecord.transaction_promotion_unlock_reason)
      .where(%Q{
        EXISTS (
          SELECT 1
          FROM intuit_transactions
          WHERE intuit_transactions.user_id = wallets.userID
            AND intuit_transactions.post_date > '2013-10-17'
            AND intuit_transactions.post_date < '2013-10-31'
        )}
      )
    Plink::WalletQueryService.new(relation).plink_point_users_with_wallet
  end

  def user_with_offer_in_wallet(offers_virtual_currency_id)
    Plink::UserRecord.includes(:wallet_item_records).where('walletItems.offersVirtualCurrencyID = ?', offers_virtual_currency_id)
  end

  def offers_with_end_date_between_given_dates(starting_date, ending_date)
    Plink::OfferRecord.where('endDate >= ? AND endDate < ?', starting_date, ending_date)
      .includes(:advertiser)
  end
end
