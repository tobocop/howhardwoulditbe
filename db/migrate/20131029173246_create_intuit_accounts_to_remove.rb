class CreateIntuitAccountsToRemove < ActiveRecord::Migration
  def up
    create_table :intuit_accounts_to_remove do |t|
      t.integer :user_id
      t.integer :intuit_account_id
      t.timestamps
    end
  end

  def down
    drop_table :intuit_accounts_to_remove
  end
end
