require 'spec_helper'
describe Lyris::User do
  let(:lyris_config) {Lyris::Config.instance}
  let(:email) { "automated-#{Time.zone.now.to_i}@testing.com" }
  let(:valid_data) {
    {
      bank_registered: true,
      birthday: 10.years.ago.to_date,
      first_name: 'toby',
      gender: 'Male',
      incentivized_on_card_reg: true,
      incentivized_on_join: true,
      is_subscribed: true,
      last_name: 'derpston',
      registration_affiliate_id: 2,
      registration_date: 1.day.ago.to_date,
      state: 'CO',
      user_id: 382,
      virtual_currency: 'Plink Points',
      zip: 80204
    }
  }

  subject(:lyris_user) {Lyris::User.new(lyris_config, email, valid_data)}

  it 'manages a user on the lyris list', flaky: true do
    lyris_add_response = lyris_user.add_to_list
    lyris_add_response.should be_successful

    lyris_removal_response = lyris_user.remove_from_list
    lyris_removal_response.should be_successful
  end
end

