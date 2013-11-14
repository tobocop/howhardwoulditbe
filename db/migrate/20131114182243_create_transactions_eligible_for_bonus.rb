class CreateTransactionsEligibleForBonus < ActiveRecord::Migration
  def up
    create_table :transactions_eligible_for_bonus do |t|
      t.boolean :processed
      t.integer :intuit_archived_transaction_id
      t.integer :offer_id
      t.integer :offers_virtual_currency_id
      t.integer :user_id

      t.timestamps
    end
  end

  def down
    drop_table :transactions_eligible_for_bonus
  end
end
