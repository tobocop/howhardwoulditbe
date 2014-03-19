class RenameReceiptSubmissionColumns < ActiveRecord::Migration
  def up
    rename_column :receipt_submissions, :from, :from_address
    rename_column :receipt_submissions, :to, :to_address
  end

  def down
    rename_column :receipt_submissions, :from_address, :from
    rename_column :receipt_submissions, :to_address, :to
  end
end
