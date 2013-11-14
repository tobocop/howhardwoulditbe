class AddLinkToHeroPromotions < ActiveRecord::Migration
  def change
    add_column :hero_promotions, :link, :text
  end
end
