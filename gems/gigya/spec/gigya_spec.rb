require 'spec_helper'

describe Gigya do
  describe 'initialization' do
    it 'raises when no api_key is specified' do
      expect {
        Gigya.new(secret: 'mocked')
      }.to raise_error(KeyError, 'key not found: :api_key')
    end

    it 'raises when api_key is blank' do
      expect {
        Gigya.new(api_key: nil, secret: 'fake')
      }.to raise_error(ArgumentError, 'api_key must be specified')
    end

    it 'raises when no secret is specified' do
      expect {
        Gigya.new(api_key: 'mocked')
      }.to raise_error(KeyError, 'key not found: :secret')
    end

    it 'raises when secret is blank' do
      expect {
        Gigya.new(api_key: 'mocked', secret: nil)
      }.to raise_error(ArgumentError, 'secret must be specified')
    end

    it 'stores the api_key' do
      gigya = Gigya.new(api_key: 'mocked_api_key', secret: 'mocked')
      gigya.configuration.api_key.should == 'mocked_api_key'

     end

    it 'stores the secret' do
      gigya = Gigya.new(api_key: 'mocked_api_key', secret: 'mocked_secret')
      gigya.configuration.secret.should == 'mocked_secret'
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

    it 'calls gigya to notify of a login of an existing user' do
      http_mock = mock
      Gigya::Http.stub(:new).with(gigya.configuration, api_method: 'socialize.notifyLogin', url_params: { siteUID: 12334, format: 'json', userInfo: { firstName: "bob", email: "bob@example.com"}.to_json }) { http_mock }
      http_mock.stub(:perform_request) { stub(body: 'somejson') }

      response_stub = stub
      Gigya::NotifyLoginResponse.stub(:from_json).with('somejson') { response_stub }

      response = gigya.notify_login(mock_params)
      response.should == response_stub
    end

    it "includes the new_user flag in the request when specified" do
      http_stub = mock(perform_request: stub(body: '{}'))
      Gigya::Http.should_receive(:new).with(gigya.configuration, api_method: 'socialize.notifyLogin', url_params: { siteUID: 12334, newUser: true, format: 'json', userInfo: { firstName: "bob", email: "bob@example.com"}.to_json }) { http_stub }
      gigya.notify_login(mock_params.merge(new_user: true))
    end
  end
end