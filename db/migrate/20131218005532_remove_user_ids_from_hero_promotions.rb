class RemoveUserIdsFromHeroPromotions < ActiveRecord::Migration
  def up
    remove_column :hero_promotions, :user_ids
  end

  def down
    add_column :hero_promotions, :user_ids, :text
  end
end
