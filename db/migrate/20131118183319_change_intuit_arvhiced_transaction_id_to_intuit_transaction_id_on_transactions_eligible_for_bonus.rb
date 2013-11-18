class ChangeIntuitArvhicedTransactionIdToIntuitTransactionIdOnTransactionsEligibleForBonus < ActiveRecord::Migration
  def up
    rename_column :transactions_eligible_for_bonus, :intuit_archived_transaction_id, :intuit_transaction_id
  end

  def down
    rename_column :transactions_eligible_for_bonus, :intuit_transaction_id, :intuit_archived_transaction_id
  end
end
