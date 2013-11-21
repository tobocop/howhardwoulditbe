class UpdateIntuitTransactionIdToBigint < ActiveRecord::Migration
  def up
    change_table :transactions_eligible_for_bonus do |t|
      t.change :intuit_transaction_id, :integer, :limit => 8
    end
  end

  def down
    change_table :transactions_eligible_for_bonus do |t|
      t.change :intuit_transaction_id, :integer
    end
  end
end
