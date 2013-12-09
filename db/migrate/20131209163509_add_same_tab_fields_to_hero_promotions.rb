class AddSameTabFieldsToHeroPromotions < ActiveRecord::Migration
  def change
    add_column :hero_promotions, :same_tab_one, :boolean
    add_column :hero_promotions, :same_tab_two, :boolean
  end
end
