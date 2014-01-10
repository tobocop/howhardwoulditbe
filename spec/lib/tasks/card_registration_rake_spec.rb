require 'spec_helper'

describe 'card_registration:remove_old_intuit_account_request_records' do
  include_context 'rake'

  let!(:intuit_account_request) { create_intuit_request }
  let!(:old_intuit_account_request) do
    request = create_intuit_request
    request.update_attribute(:created_at, 31.minutes.ago)
    request
  end

  it 'removes any request that is more than 30 minutes old' do
    capture_stdout { subject.invoke }

    expect {
      old_intuit_account_request.reload
    }.to raise_error ActiveRecord::RecordNotFound
  end

  it 'does not remove a recent request' do
    capture_stdout { subject.invoke }

    expect {
      intuit_account_request.reload
    }.to_not raise_error ActiveRecord::RecordNotFound
  end
end
