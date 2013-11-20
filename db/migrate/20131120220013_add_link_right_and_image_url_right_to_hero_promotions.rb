class AddLinkRightAndImageUrlRightToHeroPromotions < ActiveRecord::Migration
  def change
    add_column :hero_promotions, :link_right, :string
    add_column :hero_promotions, :image_url_right, :string
  end
end
