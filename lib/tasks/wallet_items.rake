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
    # These IDs correspond to the ColdFusion WalletSlotID & WalletSlotTypeID
    JOIN_UNLOCK_SLOT_ID = 1
    TRANSACTION_UNLOCK_SLOT_ID = 2
    REFERRAL_UNLOCK_SLOT_ID = 3

    Plink::WalletItemRecord.legacy_wallet_items_requiring_conversion.each do |wallet_item|
      case
        when wallet_item.wallet_slot_id == JOIN_UNLOCK_SLOT_ID
          wallet_item.unlock_reason = 'join'
        when wallet_item.wallet_slot_id == TRANSACTION_UNLOCK_SLOT_ID && wallet_item.attributes['has_qualifying_transaction']
          wallet_item.unlock_reason = 'transaction'
        when wallet_item.wallet_slot_id == REFERRAL_UNLOCK_SLOT_ID && wallet_item.attributes['has_referral'] == 1
          wallet_item.unlock_reason = 'referral'
      end

      wallet_item.save!
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

end