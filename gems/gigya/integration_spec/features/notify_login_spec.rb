require 'integration_spec_helper'
require 'securerandom'

describe Gigya do
  let(:gigya) { Gigya.new(Gigya::Config.instance) }

  it 'notifies that an existing user is logging in' do
    uuid = SecureRandom.uuid
    response = gigya.notify_login(site_user_id: uuid, email: "#{uuid}@example.com", first_name: 'bob')

    response.should be_successful

    # Test that the user actually wound up in Gigya's DB
    # Make sure the e-mail address is populated when returned. We saw it not populate once, no idea how.
  end
end