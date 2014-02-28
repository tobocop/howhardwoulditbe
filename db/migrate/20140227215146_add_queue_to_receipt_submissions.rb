class AddQueueToReceiptSubmissions < ActiveRecord::Migration
  def change
    add_column :receipt_submissions, :queue, :integer
    add_column :receipt_submissions, :approved, :boolean, default: false
    add_column :receipt_submissions, :needs_additional_information, :boolean, default: false
    add_column :receipt_submissions, :date_of_purchase, :date
    add_column :receipt_submissions, :dollar_amount, :decimal, :precision => 8, :scale => 2
    add_column :receipt_submissions, :receipt_promotion_id, :integer
  end
end
