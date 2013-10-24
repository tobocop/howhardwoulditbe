require 'spec_helper'

describe 'lyris:update_modified_users' do
  include_context 'rake'

  let!(:virtual_currency) { create_virtual_currency(name: 'rake vc') }
  let!(:user_modified_yesterday) {
    create_user(
      email: 'user_modified_yesterday@plink.com',
      modified: 1.day.ago
    )
  }
  let!(:user_modified_today) {
    create_user(
      email: 'user_modified_today@plink.com',
      modified: Time.zone.now
    )
  }
  let!(:user_modified_two_days_ago) {
    create_user(
      email: 'user_modified_two_days_ago@plink.com',
      modified: 2.days.ago
    )
  }

  let(:user_data) { {demo: 'data'} }
  let(:lyris_user_double) { double(update: true) }
  let(:lyris_success_response) { double(successful?: true, data: 'email added') }
  let(:lyris_other_error_response) { double(successful?: false, data: 'It failed') }
  let(:lyris_update_error_response) { double(successful?: false, data: "Can't find email address") }

  it 'updates users in lyris that have a modified date of yesterday' do
    Lyris::UserDataCollector.should_receive(:new).with(
      user_modified_yesterday.id, 'rake vc'
    ).and_return(user_data)

    Lyris::User.should_receive(:new).with(
      Lyris::Config.instance,
      'user_modified_yesterday@plink.com',
      user_data
    ).and_return(lyris_user_double)

    lyris_user_double.should_receive(:update).and_return(lyris_success_response)

    subject.invoke
  end

  it 'tries to add the user to the lyris list if the update cannot find the email in lyris' do
    Lyris::UserDataCollector.stub(new: user_data)
    Lyris::User.stub(new: lyris_user_double)
    lyris_user_double.stub(update: lyris_update_error_response)

    lyris_user_double.should_receive(:add_to_list).and_return(lyris_success_response)

    subject.invoke
  end

  it 'sends errors to Exceptional in production if an update fails' do
    module Exceptional ; class Catcher ; end ; end

    Rails.env.stub(:production?).and_return(true)

    Exceptional::Catcher.should_receive(:handle)

    Lyris::UserDataCollector.stub(new: user_data)
    Lyris::User.stub(new: lyris_user_double)
    lyris_user_double.stub(update: lyris_other_error_response)

    subject.invoke
  end
end
