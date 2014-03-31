class AddAdvertiserIdToReceiptPromotions < ActiveRecord::Migration
  def change
    add_column :receipt_promotions, :advertiser_id, :integer
  end
end
