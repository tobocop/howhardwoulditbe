require 'spec_helper'
require 'csv'

describe 'export_users:users_removed_for_103_errors' do
  include_context 'rake'

  let!(:user_records) {
    [
      {
        "email_address" => "removed_user@somedomain.com",
        "name" => "Removed User",
        "first_name" => "Removed",
        "user_id" => "123",
        "institution_name" => "Some Bank",
        "last_tracked_date" => 10.days.ago.strftime('%m/%d/%Y'),
        "id" => "1"
      }
    ]
  }
  let!(:token) { 'XXXLOGINTOKENXXX' }
  let(:csv) { double(:<< => []) }

  before do
    PlinkAdmin::UserQueryService.stub(:users_removed_for_103_errors).
      and_return(user_records)
    CSV.stub(:open).and_yield(csv)
    AutoLoginService.stub(:generate_token).and_return(token)
  end

  it 'gets a list of users removed for error 103 from the warehouse' do
    PlinkAdmin::UserQueryService.should_receive(:users_removed_for_103_errors).
      and_return(user_records)

    subject.invoke
  end

  it 'opens a csv file for writing with force_quotes' do
    CSV.should_receive(:open).
      with('users_removed_for_103_errors.csv','w',{ force_quotes:true })

    subject.invoke
  end

  it 'generates a login token for each user' do
    AutoLoginService.should_receive(:generate_token).with(123).and_return(token)

    subject.invoke
  end

  it 'writes a header to the file' do
    csv.should_receive(:<<).with(user_records[0].keys << 'token').
      exactly(:once)

    subject.invoke
  end

  it 'writes each record to the file' do
    csv.should_receive(:<<).with(user_records[0].values << token).
      at_least(:once)

    subject.invoke
  end
end
