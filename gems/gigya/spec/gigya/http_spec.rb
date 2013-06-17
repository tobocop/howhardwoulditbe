require 'spec_helper'

describe Gigya::Http do
  let(:valid_params) { { api_key: 'mocked_api_key', secret: 'secret', api_method: 'socialize.fake', url_params: {userInfo: {firstName: 'Bob'}} } }

  it 'initializes with an API key' do
    http = Gigya::Http.new(valid_params)
    http.api_key.should == 'mocked_api_key'
  end

  it 'raises if initialized without api_key' do
    expect {
      Gigya::Http.new(valid_params.except(:api_key))
    }.to raise_exception(KeyError, 'key not found: :api_key')
  end

  it 'initializes with a secret' do
    http = Gigya::Http.new(valid_params)
    http.secret.should == 'secret'
  end

  it 'raises if initialized without secret' do
    expect {
      Gigya::Http.new(valid_params.except(:secret))
    }.to raise_exception(KeyError, 'key not found: :secret')
  end

  it 'initializes with an api_method' do
    http = Gigya::Http.new(valid_params)
    http.api_method.should == 'socialize.fake'
  end

  it 'raises if no api_method is passed' do
    expect {
      Gigya::Http.new(valid_params.except(:api_method))
    }.to raise_exception(KeyError, 'key not found: :api_method')
  end

  it 'initializes with url_params' do
    http = Gigya::Http.new(valid_params)
    http.url_params.should == {userInfo: {firstName: 'Bob'}}
  end

  it 'raises if no url_params are passed' do
    expect {
      Gigya::Http.new(valid_params.except(:url_params))
    }.to raise_exception(KeyError, 'key not found: :url_params')
  end

  describe '#perform_request' do
    let(:gigya_http) { Gigya::Http.new(valid_params) }

    it 'sends the request to Gigya' do
      http_mock = mock
      Net::HTTP.should_receive(:new).with('socialize-api.gigya.com', 443) { http_mock }
      http_mock.should_receive(:use_ssl=).with(true)
      http_mock.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

      request_mock = mock
      Net::HTTP::Get.should_receive(:new).with('/socialize.fake?apiKey=mocked_api_key&secret=secret&userInfo=%7B%3AfirstName%3D%3E%22Bob%22%7D') { request_mock }

      http_mock.should_receive(:request).with(request_mock)

      gigya_http.perform_request
    end

  end
end