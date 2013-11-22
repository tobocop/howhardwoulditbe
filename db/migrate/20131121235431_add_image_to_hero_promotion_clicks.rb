class AddImageToHeroPromotionClicks < ActiveRecord::Migration
  def change
    add_column :hero_promotion_clicks, :image, :string
  end
end
