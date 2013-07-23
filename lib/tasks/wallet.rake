namespace :wallet do
  desc 'Migrate wallet items to use to Rails STI'
  task migrate_wallet_items: :environment do
    update_populated_and_open_wallet_item_records
    fill_in_missing_locked_slots
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