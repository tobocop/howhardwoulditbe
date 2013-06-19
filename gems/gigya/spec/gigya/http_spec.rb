require 'spec_helper'

describe Gigya::Http do
  let(:configuration) { Gigya::Config.instance }
  let(:valid_params) { { api_method: 'socialize.fake', url_params: {userInfo: {firstName: 'Bob'}} } }

  it 'initializes with an configuration' do
    http = Gigya::Http.new(configuration, valid_params)
    http.configuration.should == configuration
  end

  it 'initializes with an api_method' do
    http = Gigya::Http.new(configuration, valid_params)
    http.api_method.should == 'socialize.fake'
  end

  it 'raises if no api_method is passed' do
    expect {
      Gigya::Http.new(configuration, valid_params.except(:api_method))
    }.to raise_exception(KeyError, 'key not found: :api_method')
  end

  it 'initializes with url_params' do
    http = Gigya::Http.new(configuration, valid_params)
    http.url_params.should == {userInfo: {firstName: 'Bob'}}
  end

  it 'raises if no url_params are passed' do
    expect {
      Gigya::Http.new(configuration, valid_params.except(:url_params))
    }.to raise_exception(KeyError, 'key not found: :url_params')
  end

  describe '#perform_request' do
    let(:gigya_http) { Gigya::Http.new(configuration, valid_params) }

    it 'sends the request to Gigya' do
      http_mock = mock
      Net::HTTP.should_receive(:new).with('socialize-api.gigya.com', 443) { http_mock }
      http_mock.should_receive(:use_ssl=).with(true)
      http_mock.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

      request_mock = mock
      Net::HTTP::Get.should_receive(:new).with('/socialize.fake?apiKey=1234&secret=my-secret&userInfo=%7B%3AfirstName%3D%3E%22Bob%22%7D') { request_mock }

      http_mock.should_receive(:request).with(request_mock)

      gigya_http.perform_request
    end
  end
end