class AddUserIdsToHeroPromotions < ActiveRecord::Migration
  def change
    add_column :hero_promotions, :user_ids, :text
  end
end
