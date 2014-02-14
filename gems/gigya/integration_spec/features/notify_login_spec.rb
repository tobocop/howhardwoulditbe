require 'integration_spec_helper'
require 'securerandom'

describe Gigya do
  let(:gigya) { Gigya.new(Gigya::Config.instance) }

  it 'notifies that an existing user is logging in' do
    uuid = SecureRandom.uuid
    response = gigya.notify_login(site_user_id: uuid, email: "#{uuid}@example.com", first_name: 'bob')

    response.should be_successful

    get_user_info = gigya.get_user_info(uuid)

    get_user_info.should be_successful
    parsed_json = JSON.parse(get_user_info.json)
    parsed_json['email'].should == "#{uuid}@example.com"
  end
end
