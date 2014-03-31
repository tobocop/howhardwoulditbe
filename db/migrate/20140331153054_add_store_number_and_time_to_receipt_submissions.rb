class AddStoreNumberAndTimeToReceiptSubmissions < ActiveRecord::Migration
  def change
    add_column :receipt_submissions, :store_number, :string
    add_column :receipt_submissions, :time_of_purchase, :time
  end
end
