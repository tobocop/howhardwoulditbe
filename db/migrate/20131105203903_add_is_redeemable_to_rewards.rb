class AddIsRedeemableToRewards < ActiveRecord::Migration
  def change
    add_column :loot, :is_redeemable, :boolean
  end
end
