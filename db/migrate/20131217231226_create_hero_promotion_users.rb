class CreateHeroPromotionUsers < ActiveRecord::Migration
  def up
    create_table :hero_promotion_users do |t|
      t.integer :hero_promotion_id
      t.integer :user_id
    end
  end

  def down
    drop_table :hero_promotion_users
  end
end
