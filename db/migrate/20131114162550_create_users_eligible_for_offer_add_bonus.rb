class CreateUsersEligibleForOfferAddBonus < ActiveRecord::Migration
  def up
    create_table :users_eligible_for_offer_add_bonus do |t|
      t.integer :user_id
      t.integer :offers_virtual_currency_id

      t.timestamps
    end
  end

  def down
    drop_table :users_eligible_for_offer_add_bonus
  end
end
