class RemoveRawColumnsFromReceiptSubmissions < ActiveRecord::Migration
  def up
    remove_column :receipt_submissions, :raw_body
    remove_column :receipt_submissions, :raw_html
    remove_column :receipt_submissions, :raw_text
  end

  def down
    add_column :receipt_submissions, :raw_body, :text
    add_column :receipt_submissions, :raw_html, :text
    add_column :receipt_submissions, :raw_text, :text
  end
end
