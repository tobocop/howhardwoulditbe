namespace :wallet_items do
  desc 'Migrate wallet items to use to Rails STI'
  task migrate: :environment do
    update_populated_and_open_wallet_item_records
    fill_in_missing_locked_slots
  end

  desc "Unlock wallet items for users who have a qualifying transaction"
  task unlock_transaction_wallet_item: :environment do
    Plink::WalletItemUnlockingService.unlock_transaction_items_for_eligible_users
  end

  desc 'Sets the unlock_reason for wallet items for legacy users'
  task set_unlock_reason: :environment do
    set_unlock_reason
  end

  desc 'Removes all expired offers from users wallets and end dates their associated tiers'
  task remove_expired_offers: :environment do
    expired_offers = Plink::OfferRecord.where('endDate < ? AND endDate > ?', Date.current, 7.days.ago.to_date)

    expired_offers.each do |expired_offer|
      expired_offer.active_offers_virtual_currencies.each do |offers_virtual_currency|

        offers_virtual_currency.tiers.each do |tier_record|
          tier_record.update_attributes(:end_date => expired_offer.end_date)
        end

        user_with_offer_in_wallet = Plink::UserRecord
        .includes(:wallet_item_records)
        .where('walletItems.offersVirtualCurrencyID = ?', offers_virtual_currency.id)

        user_with_offer_in_wallet.each do |user_record|
          Plink::RemoveOfferFromWalletService.new(user_record.id, expired_offer.id).remove_offer
        end
      end
    end
  end

private

  def update_populated_and_open_wallet_item_records
    statement = "UPDATE walletItems
                  SET type = CASE
                    WHEN usersAwardPeriodID IS NOT NULL THEN 'Plink::PopulatedWalletItemRecord'
                    ELSE 'Plink::OpenWalletItemRecord'
                  END
                  WHERE type IS NULL"

    ActiveRecord::Base.connection.execute(statement)
  end

  def fill_in_missing_locked_slots
    statement = "INSERT INTO [dbo].[walletItems]
    ([walletID]
    ,[advertiserID_old]
    ,[virtualCurrencyID_old]
    ,[usersAwardPeriodID]
    ,[created]
    ,[modified]
    ,[isActive]
    ,[walletSlotID]
    ,[walletSlotTypeID]
    ,[offersVirtualCurrencyID]
    ,[type])
    SELECT walletID,
           null,
           null,
           null,
           getDate(),
           getDate(),
           1,
           1,
           1,
           null,
           'Plink::LockedWalletItemRecord'
    FROM walletItems
    GROUP BY walletID
    HAVING COUNT(1) < 5"

    2.times { ActiveRecord::Base.connection.execute(statement) }
  end

  def set_unlock_reason
    statement = %Q{
      UPDATE walletItems
        SET walletItems.unlock_reason = query.unlock_reason
      FROM walletItems
      INNER JOIN (
        SELECT
          wi.walletItemID,
          CASE
          WHEN wi.walletSlotTypeID = 1 THEN 'join'
          WHEN wi.walletSlotTypeID = 2 THEN 'transaction'
          WHEN wi.walletSlotTypeID = 3 THEN 'referral'
          END AS unlock_reason
        FROM walletItems wi
        INNER JOIN wallets w WITH(NOLOCK) ON wi.walletID = w.walletID
        WHERE wi.TYPE <> 'Plink::LockedWalletItemRecord'
        AND wi.unlock_reason IS NULL
      ) query ON walletItems.walletItemID = query.walletItemID
    }

    ActiveRecord::Base.connection.execute(statement)
  end

end
