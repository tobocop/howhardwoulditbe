class AddIndexesToHeroPromotionUsers < ActiveRecord::Migration
  def change
    add_index :hero_promotion_users, [:hero_promotion_id, :user_id]
  end
end
