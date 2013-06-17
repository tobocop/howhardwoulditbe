require 'spec_helper'
require 'securerandom'

describe Gigya do
  let(:gigya) { Gigya.new(api_key: GIGYA_KEYS['api_key'], secret: GIGYA_KEYS['secret']) }

  it 'notifies that an existing user is logging in' do
    uuid = SecureRandom.uuid
    response = gigya.notify_login(site_user_id: uuid, email: "#{uuid}@example.com", first_name: 'bob')

    response.should be_successful

    # Test that the user actually wound up in Gigya's DB
  end
end