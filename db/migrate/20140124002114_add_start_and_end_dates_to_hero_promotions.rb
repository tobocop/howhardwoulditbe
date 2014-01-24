class AddStartAndEndDatesToHeroPromotions < ActiveRecord::Migration
  def change
     add_column :hero_promotions, :end_date, :datetime
     add_column :hero_promotions, :start_date, :datetime
  end
end
