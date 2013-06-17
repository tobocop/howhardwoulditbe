require 'spec_helper'

describe Gigya do
  describe 'initialization' do
    it 'raises when no api_key is specified' do

      expect {
        Gigya.new(secret: 'mocked')
      }.to raise_error(KeyError, 'key not found: :api_key')
    end

    it 'raises when no secret is specified' do

      expect {
        Gigya.new(api_key: 'mocked')
      }.to raise_error(KeyError, 'key not found: :secret')
    end

    it 'stores the api_key' do

      gigya = Gigya.new(api_key: 'mocked_api_key', secret: 'mocked')
      gigya.api_key.should == 'mocked_api_key'

     end

    it 'stores the secret' do
      gigya = Gigya.new(api_key: 'mocked_api_key', secret: 'mocked_secret')
      gigya.secret.should == 'mocked_secret'
    end
  end

  describe 'notify_login' do
    let(:gigya) { Gigya.new(api_key: GIGYA_KEYS['api_key'], secret: GIGYA_KEYS['secret']) }

    let(:mock_params) { { first_name: 'bob', email:'bob@example.com', site_user_id: 12334 } }

    it 'raises when a site_user_id is not passed in' do
      expect {
        gigya.notify_login(mock_params.except(:site_user_id))
      }.to raise_exception(KeyError, 'key not found: :site_user_id')
    end

    it 'raises when an email is not passed in ' do
      expect {
        gigya.notify_login(mock_params.except(:email))
      }.to raise_error(KeyError, 'key not found: :email')
    end

    it 'raises when a no first_name is passed in' do
      expect {
        gigya.notify_login(mock_params.except(:first_name))
      }.to raise_error(KeyError, 'key not found: :first_name')
    end

    it 'calls gigya to notify of a login of a new user' do
      response = gigya.notify_login(mock_params)
      response.should be_a(Gigya::NotifyLoginResponse)

      response.status_code.should == 200
      response.should be_successful
      response.cookie_name.should_not be_blank
      response.cookie_value.should_not be_blank
      response.cookie_path.should == "/"
      response.cookie_domain.should_not be_blank
    end

    it "includes the new_user flag in the request when specified"
    it "does not include the new_user flag in the request if it is falsy"
  end
end