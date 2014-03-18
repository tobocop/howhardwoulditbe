class CreateReceiptPostbacks < ActiveRecord::Migration
  def up
    create_table :receipt_postbacks do |t|
      t.boolean :processed, default: false
      t.integer :event_id
      t.integer :receipt_promotion_postback_url_id
      t.string :posted_url

      t.timestamps
    end
  end

  def down
    drop_table :receipt_postbacks
  end
end
