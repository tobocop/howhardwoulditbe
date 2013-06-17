require 'spec_helper'

describe Gigya::NotifyLoginResponse do
  let(:valid_params) { {status_code: 200} }

  describe '.new' do
    it 'stores the status code' do
      response = Gigya::NotifyLoginResponse.new(valid_params)
      response.status_code.should == 200
    end

    it 'raises an exception if no status code is provided' do
      expect { Gigya::NotifyLoginResponse.new() }.to raise_error(KeyError, 'key not found: :status_code')
    end

    it 'stores a cookie_name' do
      response = Gigya::NotifyLoginResponse.new(valid_params.merge(cookie_name: 'test'))
      response.cookie_name.should == 'test'
    end

    it 'stores a cookie_value' do
      response = Gigya::NotifyLoginResponse.new(valid_params.merge(cookie_value: 'abc123'))
      response.cookie_value.should == 'abc123'
    end

    it 'stores a cookie_domain' do
      response = Gigya::NotifyLoginResponse.new(valid_params.merge(cookie_domain: 'test_domain'))
      response.cookie_domain.should == 'test_domain'
    end

    it 'stores a cookie_path' do
      response = Gigya::NotifyLoginResponse.new(valid_params)
      response.cookie_path.should == '/'
    end

    it 'stores an error_code' do
      response = Gigya::NotifyLoginResponse.new(valid_params.merge(error_code: 10))
      response.error_code.should == 10
    end

    it 'defaults an error_code to 0 if not provided' do
      response = Gigya::NotifyLoginResponse.new(valid_params)
      response.error_code.should == 0
    end


  end

  describe '.successful?' do
    it 'is successful with an error_code of 0 and status_code of 200' do
      response = Gigya::NotifyLoginResponse.new(valid_params)
      response.should be_successful
    end

    it 'is unsuccessful if the error_code is not 0' do
      response = Gigya::NotifyLoginResponse.new(valid_params.merge(error_code: 1))
      response.should_not be_successful
    end

    it 'is unsuccessful if the status_code is not 200' do
      response = Gigya::NotifyLoginResponse.new(valid_params.merge(status_code: 1))
      response.should_not be_successful
    end

  end

  describe '.from_json' do
    let(:json_response) do
      '{
          "UID": "12334",
          "UIDSignature": "TdDwFjK+NVBx5EdYs84jM6Zt0qA=",
          "signatureTimestamp": "1371498826",
          "cookieName": "gac_3_q0axgZ5uEFDE2dCOzCp5M5gKD9eCa3xKwluLv-SWpY4Z2OwjA0zlNopugciH_r_F",
          "cookieValue": "VC1_342D4A3C0C3201491A9A1136910BEC97__GA5aHw0sAAhOEFhrpSGFqWdUr4gqKzNwA0DKQaE18Hl28yfUVdUpu_mRBrtILJPSKQcSEPALyqCVMm8ePRN4fh1lkBNrANYi3mkeGOGflXcXHuRg8QOi16f4A1cWjglKbDUYCsSk1Pg6rZqs2EzNg==",
          "cookieDomain": "plink.dev",
          "cookiePath": "/",
          "statusCode": 200,
          "errorCode": 0,
          "statusReason": "OK",
          "callId": "119f17fd68ee4cd5bc1f20d3268ed718"
      }'
    end

    it 'initializes a new response object after parsing the json' do
      Gigya::NotifyLoginResponse.should_receive(:new).with({
                                                               status_code: 200,
                                                               cookie_name: 'gac_3_q0axgZ5uEFDE2dCOzCp5M5gKD9eCa3xKwluLv-SWpY4Z2OwjA0zlNopugciH_r_F',
                                                               cookie_value: 'VC1_342D4A3C0C3201491A9A1136910BEC97__GA5aHw0sAAhOEFhrpSGFqWdUr4gqKzNwA0DKQaE18Hl28yfUVdUpu_mRBrtILJPSKQcSEPALyqCVMm8ePRN4fh1lkBNrANYi3mkeGOGflXcXHuRg8QOi16f4A1cWjglKbDUYCsSk1Pg6rZqs2EzNg==',
                                                               cookie_domain: 'plink.dev',
                                                               error_code: 0
                                                           })

      Gigya::NotifyLoginResponse.from_json(json_response)
    end

    it 'returns the result of initialization' do
      response = stub
      Gigya::NotifyLoginResponse.stub(:new) { response }
      Gigya::NotifyLoginResponse.from_json(json_response).should == response
    end


  end
end