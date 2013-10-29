class AddUsersInstitutionIdToIntuitAccountsToRemove < ActiveRecord::Migration
  def change
    add_column :intuit_accounts_to_remove, :users_institution_id, :integer
  end
end
