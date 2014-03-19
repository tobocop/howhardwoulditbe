namespace :receipt_submissions do
  desc 'One time task to update approved / needs info columns to new status column'
  task update_status: :environment do
    Plink::ReceiptSubmissionRecord.where(approved: true, status: nil, needs_additional_information: false).
      update_all(status: 'approved')

    Plink::ReceiptSubmissionRecord.where(approved: false, status: nil, needs_additional_information: true).
      update_all(status: 'other', status_reason: 'Updated from old needs_additional_information = true')

    Plink::ReceiptSubmissionRecord.where(approved: false, status: nil, needs_additional_information: false).
      update_all(status: 'pending')
  end
end

