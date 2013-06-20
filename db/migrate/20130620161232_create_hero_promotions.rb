class CreateHeroPromotions < ActiveRecord::Migration
  def change
    create_table :hero_promotions do |t|
      t.string    :image_url
      t.string    :title
      t.integer   :display_order

      t.timestamps
    end
  end
end
