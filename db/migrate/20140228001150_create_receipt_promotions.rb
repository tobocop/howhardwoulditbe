class CreateReceiptPromotions < ActiveRecord::Migration
  def up
    create_table :receipt_promotions do |t|
      t.string :name
      t.string :description
      t.date :start_date
      t.date :end_date
      t.integer :award_type_id

      t.timestamps
    end
  end

  def down
    drop_table :receipt_promotions
  end
end
