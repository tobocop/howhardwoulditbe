class AddReferralEntriesToEntries < ActiveRecord::Migration
  def change
    add_column :entries, :referral_entries, :integer
  end
end
