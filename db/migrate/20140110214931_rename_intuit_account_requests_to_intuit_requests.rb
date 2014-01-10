class RenameIntuitAccountRequestsToIntuitRequests < ActiveRecord::Migration
  def up
    rename_table :intuit_account_requests, :intuit_requests
  end

  def down
    rename_table :intuit_requests, :intuit_account_requests
  end
end
