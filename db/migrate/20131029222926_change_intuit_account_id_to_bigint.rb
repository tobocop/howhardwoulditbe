class ChangeIntuitAccountIdToBigint < ActiveRecord::Migration
  def up
    change_table :intuit_accounts_to_remove do |t|
      t.change :intuit_account_id, :integer, :limit => 8
    end
  end

  def down
    change_table :intuit_accounts_to_remove do |t|
      t.change :intuit_account_id, :integer
    end
  end
end
