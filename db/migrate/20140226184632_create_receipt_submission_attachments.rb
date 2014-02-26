class CreateReceiptSubmissionAttachments < ActiveRecord::Migration
  def up
    create_table :receipt_submission_attachments do |t|
      t.integer :receipt_submission_id
      t.string :url

      t.timestamps
    end
  end

  def down
    drop_table :receipt_submission_attachments
  end
end
