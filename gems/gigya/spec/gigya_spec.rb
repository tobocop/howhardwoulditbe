require 'spec_helper'

describe Gigya do
  let(:gigya) { Gigya.new(Gigya::Config.instance) }

  describe '#notify_login' do
    let(:mock_params) { {first_name: 'bob', email: 'bob@example.com', site_user_id: 12334} }

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
      http_mock = stub
      Gigya::Http.stub(:new).with(gigya.config, api_method: 'socialize.notifyLogin', url_params: {siteUID: 12334, format: 'json', userInfo: {firstName: "bob", email: "bob@example.com"}.to_json}) { http_mock }
      http_mock.stub(:perform_request) { stub(body: 'somejson') }

      response_stub = stub
      Gigya::NotifyLoginResponse.stub(:from_json).with('somejson') { response_stub }

      response = gigya.notify_login(mock_params)
      response.should == response_stub
    end

    it 'includes the new_user flag in the request when specified' do
      http_stub = mock(perform_request: stub(body: '{}'))
      Gigya::Http.should_receive(:new).with(gigya.config, api_method: 'socialize.notifyLogin', url_params: {siteUID: 12334, newUser: true, format: 'json', userInfo: {firstName: "bob", email: "bob@example.com"}.to_json}) { http_stub }
      gigya.notify_login(mock_params.merge(new_user: true))
    end
  end

  describe '#notify_registration' do
    let(:mock_params) { {gigya_id: '123-456', site_user_id: 123} }

    it 'raises when gigya_id is not specified' do
      expect {
        gigya.notify_registration(mock_params.except(:gigya_id))
      }.to raise_exception(KeyError, 'key not found: :gigya_id')
    end

    it 'raises when site_user_id is not specified' do
      expect {
        gigya.notify_registration(mock_params.except(:site_user_id))
      }.to raise_exception(KeyError, 'key not found: :site_user_id')
    end

    it 'calls gigya to notify of a registration' do
      http_stub = stub
      Gigya::Http.stub(:new).with(gigya.config, api_method: 'socialize.notifyRegistration', url_params: {siteUID: 123, format: 'json', UID: '123-456'}) { http_stub }
      http_stub.stub(:perform_request) { stub(body: 'somejson') }

      response_stub = stub
      Gigya::GigyaResponse.stub(:from_json).with('somejson') { response_stub }

      response = gigya.notify_registration(mock_params)
      response.should == response_stub
    end
  end

  describe '#delete_user' do
    it 'deletes the user from Gigya' do
      http_stub = stub
      Gigya::Http.stub(:new).with(gigya.config, api_method: 'socialize.deleteAccount', url_params: {format: 'json', uid: '1234'}) { http_stub }
      http_stub.stub(:perform_request) { stub(body: 'somejson') }

      response_stub = stub
      Gigya::GigyaResponse.stub(:from_json).with('somejson') { response_stub }

      response = gigya.delete_user('1234')
      response.should == response_stub
    end
  end

  describe '#set_facebook_status' do
    let(:mock_params) { {gigya_id: '123-456', site_user_id: 123}}
    it 'calls gigya to update the user\'s facebook status' do
      http_stub = stub
      Gigya::Http.stub(:new).with(gigya.config, api_method: 'socialize.setStatus', url_params: {format: 'json', uid: '1234', status: 'This is a status for Facebook'}) { http_stub }
      http_stub.stub(:perform_request) { stub(body: 'somejson') }

      response_stub = stub
      Gigya::GigyaResponse.stub(:from_json).with('somejson') { response_stub }

      response = gigya.set_facebook_status('1234', 'This is a status for Facebook')
      response.should == response_stub
    end
  end

  describe '#get_user_info' do
    let(:params) { {site_user_id: 123} }
    let(:request) { double(body: 'some stuff') }
    let(:http) { double(perform_request: request) }

    before do
      Gigya::Http.stub(:new).and_return(http)
      Gigya::UserInfoResponse.stub(:from_json).and_return('another thing')
    end

    it 'gets a new gigya http object with the correct params' do
      http_params = {
        api_method: 'socialize.getUserInfo' ,
        url_params: {
          format: 'json',
          extraFields: 'languages, address, phones, education, honors, publications, patents, certifications, professionalHeadline, bio, industry, specialties, work, skills, religion, politicalView, interestedIn, relationshipStatus, hometown, favorites, likes, followersCount, followingCount, username, locale, verified, irank, timezone',
          uid: 234
        }
      }

      Gigya::Http.should_receive(:new).with(gigya.config, http_params).and_return(http)

      gigya.get_user_info(234)
    end

    it 'calls perform_request on the gigya http object' do
      http.should_receive(:perform_request).and_return(request)

      gigya.get_user_info(234)
    end

    it 'returns a new gigya user info response' do
      Gigya::UserInfoResponse.should_receive(:from_json).with('some stuff').and_return('some other stuff')

      gigya.get_user_info(234).should == 'some other stuff'
    end
  end
end
