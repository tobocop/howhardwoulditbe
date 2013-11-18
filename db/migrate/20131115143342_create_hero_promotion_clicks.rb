class CreateHeroPromotionClicks < ActiveRecord::Migration
  def up
    create_table :hero_promotion_clicks do |t|
      t.integer :hero_promotion_id
      t.integer :user_id

      t.timestamps
    end
  end

  def down
    drop_table :hero_promotion_clicks
  end
end
