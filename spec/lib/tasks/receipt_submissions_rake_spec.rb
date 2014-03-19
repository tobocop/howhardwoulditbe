require 'spec_helper'

describe 'receipt_submissions:update_status' do
  include_context 'rake'

  it 'does not update records with an existing status' do
    submission = create_receipt_submission(status: 'pending', approved: true, needs_additional_information: false)

    subject.invoke

    submission.reload.status.should == 'pending'
  end

  it 'sets records that have been approved to status of approved' do
    submission = create_receipt_submission(status: nil, approved: true, needs_additional_information: false)

    subject.invoke

    submission.reload.status.should == 'approved'
  end

  it 'updates needs_additional_information records to a status of other with a reason of old_needs_additional_information' do
    submission = create_receipt_submission(status: nil, approved: false, needs_additional_information: true)

    subject.invoke

    submission.reload.status.should == 'other'
    submission.reload.status_reason.should == 'Updated from old needs_additional_information = true'
  end

  it 'udpates records that are not approved and do not need additional info to pending' do
    submission = create_receipt_submission(status: nil, approved: false, needs_additional_information: false)

    subject.invoke

    submission.reload.status.should == 'pending'
  end
end
