class CreateReceiptSubmissions < ActiveRecord::Migration
  def up
    create_table :receipt_submissions do |t|
      t.text :body
      t.string :from
      t.string :headers
      t.text :raw_body
      t.text :raw_html
      t.text :raw_text
      t.string :subject
      t.string :to
      t.integer :user_id

      t.timestamps
    end
  end

  def down
    drop_table :receipt_submissions
  end
end
