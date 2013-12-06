require 'spec_helper'
describe Lyris::User do
  let(:lyris_config) {Lyris::Config.instance}
  let(:email) { "automated-#{Time.zone.now.to_i}@testing.com" }
  let(:new_email) { "automated-new-#{Time.zone.now.to_i}@testing.com" }
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
      login_token: 'HASHYAWESOMEDEPRIN',
      new_email: new_email,
      registration_affiliate_id: 2,
      registration_date: 1.day.ago.to_date,
      state: 'CO',
      user_id: 382,
      virtual_currency: 'Plink Points',
      zip: 80204
    }
  }

  subject(:lyris_user) {Lyris::User.new(lyris_config, email, valid_data)}

  before do
    Lyris::Config.instance.instance_variable_set(:@configured, false)
    lyris_yml = YAML.load_file(Rails.root.join('config', 'lyris.yml'))[Rails.env]

    Lyris::Config.configure do |config|
      config.site_id = lyris_yml['site_id']
      config.password = lyris_yml['password']
      config.mailing_list_id = lyris_yml['mailing_list_id']
    end
  end

  it 'manages a user on the lyris list' do
    lyris_add_response = lyris_user.add_to_list
    lyris_add_response.should be_successful

    lyris_update_response = lyris_user.update
    lyris_update_response.should be_successful

    lyris_update_email_response = lyris_user.update_email
    lyris_update_email_response.should be_successful

    lyris_user = Lyris::User.new(lyris_config, new_email, valid_data)
    lyris_removal_response = lyris_user.remove_from_list
    lyris_removal_response.should be_successful
  end
end

