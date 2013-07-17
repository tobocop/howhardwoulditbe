require 'spec_helper'

describe Gigya::GigyaResponse do
  let(:valid_params) { {status_code: 200} }

  describe '.new' do
    it 'stores the status code' do
      response = Gigya::GigyaResponse.new(valid_params)
      response.status_code.should == 200
    end

    it 'raises an exception if no status code is provided' do
      expect { Gigya::GigyaResponse.new() }.to raise_error(KeyError, 'key not found: :status_code')
    end

    it 'stores an error_code' do
      response = Gigya::GigyaResponse.new(valid_params.merge(error_code: 10))
      response.error_code.should == 10
    end

    it 'defaults an error_code to 0 if not provided' do
      response = Gigya::GigyaResponse.new(valid_params)
      response.error_code.should == 0
    end
  end

  describe '.successful?' do
    it 'is successful with an error_code of 0 and status_code of 200' do
      response = Gigya::GigyaResponse.new(valid_params)
      response.should be_successful
    end

    it 'is unsuccessful if the error_code is not 0' do
      response = Gigya::GigyaResponse.new(valid_params.merge(error_code: 1))
      response.should_not be_successful
    end

    it 'is unsuccessful if the status_code is not 200' do
      response = Gigya::GigyaResponse.new(valid_params.merge(status_code: 1))
      response.should_not be_successful
    end

  end

  describe '.from_json' do
    let(:json_response) do
      '{
          "statusCode": 200,
          "errorCode": 0,
          "errorMessage": "OK",
          "errorDetails": "Some details",
          "callId": "119f17fd68ee4cd5bc1f20d3268ed718"
      }'
    end

    it 'initializes a new response object after parsing the json' do
      Gigya::GigyaResponse.should_receive(:new).with(
        {
          status_code: 200,
          error_code: 0
        }
      )

      Gigya::GigyaResponse.from_json(json_response)
    end

    it 'returns the result of initialization' do
      response = stub
      Gigya::GigyaResponse.stub(:new) { response }
      Gigya::GigyaResponse.from_json(json_response).should == response
    end
  end
end