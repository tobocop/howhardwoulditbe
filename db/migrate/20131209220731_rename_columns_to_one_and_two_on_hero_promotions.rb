class RenameColumnsToOneAndTwoOnHeroPromotions < ActiveRecord::Migration
  def up
    rename_column :hero_promotions, :link, :link_one
    rename_column :hero_promotions, :image_url, :image_url_one
    rename_column :hero_promotions, :link_right, :link_two
    rename_column :hero_promotions, :image_url_right, :image_url_two
  end

  def down
    rename_column :hero_promotions, :link_one, :link
    rename_column :hero_promotions, :image_url_one, :image_url
    rename_column :hero_promotions, :link_two, :link_right
    rename_column :hero_promotions, :image_url_two, :image_url_right
  end
end
