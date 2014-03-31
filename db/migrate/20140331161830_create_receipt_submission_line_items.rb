class CreateReceiptSubmissionLineItems < ActiveRecord::Migration
  def up
    create_table :receipt_submission_line_items do |t|
      t.decimal :dollar_amount, precision: 8, scale: 2
      t.string :description
      t.integer :receipt_submission_id

      t.timestamps
    end
  end

  def down
    drop_table :receipt_submission_line_items
  end
end
