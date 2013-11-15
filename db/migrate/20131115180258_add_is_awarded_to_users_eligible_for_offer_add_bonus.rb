class AddIsAwardedToUsersEligibleForOfferAddBonus < ActiveRecord::Migration
  def change
    add_column :users_eligible_for_offer_add_bonus, :is_awarded, :boolean
  end
end
