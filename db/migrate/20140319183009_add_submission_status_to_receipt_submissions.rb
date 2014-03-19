class AddSubmissionStatusToReceiptSubmissions < ActiveRecord::Migration
  def change
    add_column :receipt_submissions, :status, :string, default: 'pending'
    add_column :receipt_submissions, :status_reason, :string
  end
end
