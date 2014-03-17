class CreateReceiptPromotionPostbackUrls < ActiveRecord::Migration
  def up
    create_table :receipt_promotions_postback_urls do |t|
      t.string :postback_url
      t.integer :receipt_promotion_id
      t.integer :registration_link_id

      t.timestamps
    end
  end

  def down
    drop_table :receipt_promotions_postback_urls
  end
end
