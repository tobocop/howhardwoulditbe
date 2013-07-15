class AddNameAndIsActiveToHeroPromotions < ActiveRecord::Migration
  def change
    add_column :hero_promotions, :name, :string
    add_column :hero_promotions, :is_active, :boolean, default: true
  end
end
