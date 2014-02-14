require 'spec_helper'

describe Gigya::UserInfoResponse do
  let(:valid_params) { {status_code: 200, raw_json: 'some json'} }

  describe 'initialize' do
    it 'stores the values it is initialized with' do
      response = Gigya::UserInfoResponse.new(valid_params)
      response.status_code.should == 200
      response.json.should == 'some json'
    end

    it 'defaults an error_code to 0 if not provided' do
      response = Gigya::UserInfoResponse.new(valid_params)
      response.error_code.should == 0
    end
  end

  describe '.from_json' do
    let(:parsed_json) {
      {
        'errorCode' => 234,
        'statusCode' => 200
      }
    }
    let(:user_info_response) { double }

    before do
      Gigya::UserInfoResponse.stub(:parse_json).and_return(parsed_json)
      Gigya::UserInfoResponse.stub(:new).and_return(user_info_response)
    end

    it 'parses the json input' do
      Gigya::UserInfoResponse.should_receive(:parse_json).with('some json').and_return(parsed_json)

      Gigya::UserInfoResponse.from_json('some json')
    end

    it 'returns a new user info response based on the parsed json' do
      Gigya::UserInfoResponse.should_receive(:new).
        with({error_code: 234, raw_json: 'some json', status_code: 200}).
        and_return(user_info_response)

      Gigya::UserInfoResponse.from_json('some json').should == user_info_response
    end
  end

  describe '.successful?' do
    it 'is successful with an error_code of 0 and status_code of 200' do
      response = Gigya::UserInfoResponse.new(valid_params)
      response.should be_successful
    end

    it 'is unsuccessful if the error_code is not 0' do
      response = Gigya::UserInfoResponse.new(valid_params.merge(error_code: 1))
      response.should_not be_successful
    end

    it 'is unsuccessful if the status_code is not 200' do
      response = Gigya::UserInfoResponse.new(valid_params.merge(status_code: 1))
      response.should_not be_successful
    end
  end
end
