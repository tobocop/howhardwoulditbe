require 'spec_helper'

describe IntuitUpdateRequest do
  subject(:intuit_update_request) { IntuitUpdateRequest.new(1, 482, 14, 4) }

  describe 'initialization' do
    it 'sets the user_id' do
      intuit_update_request.user_id.should == 1
    end

    it 'sets the request_id' do
      intuit_update_request.request_id.should == 482
    end

    it 'sets the intuit_institution_id' do
      intuit_update_request.intuit_institution_id.should == 14
    end

    it 'sets the intuit_institution_login_id' do
      intuit_update_request.intuit_institution_login_id.should == 4
    end
  end

  describe '#authenticate' do
    let(:intuit_request) { double(Intuit::Request, update_credentials: {status_code: '200'}) }
    let(:intuit_response) { double(Intuit::Response, parse: {hey: 'derp'}) }

    before do
      Intuit::Request.stub(:new).and_return(intuit_request)
      Intuit::Response.stub(:new).and_return(intuit_response)
      ENCRYPTION.stub(:decrypt_and_verify).and_return(['default', 'yup'])
      intuit_update_request.stub(:update_request_record)
    end

    it 'decrypts the credentials' do
      ENCRYPTION.should_receive(:decrypt_and_verify).with('user_and_pw')

      intuit_update_request.authenticate('user_and_pw')
    end

    it 'makes a call to update the users credentials in intuit' do
      Intuit::Request.should_receive(:new).with(1).and_return(intuit_request)
      intuit_request.should_receive(:update_credentials).with(14, 4, ['default', 'yup'])

      intuit_update_request.authenticate('user_and_pw')
    end

    it 'it creates a new intuit response based on the return of the intuit request' do
      Intuit::Response.should_receive(:new).with({status_code: '200'}).and_return(double(parse: true))

      intuit_update_request.authenticate('user_and_pw')
    end

    it 'updates the request record' do
      intuit_account_request_record = double
      intuit_update_request.unstub(:update_request_record)

      ENCRYPTION.should_receive(:encrypt_and_sign).with("{\"hey\":\"derp\"}").and_return('encryption')
      Plink::IntuitAccountRequestRecord.should_receive(:find).with(482).and_return(intuit_account_request_record)
      intuit_account_request_record.should_receive(:update_attributes).with(processed: true, response: 'encryption')

      intuit_update_request.authenticate('user_and_pw')
    end
  end

  describe '#respond_to_mfa' do
    let(:intuit_request) { double(Intuit::Request, update_mfa: {status_code: '200'}) }
    let(:intuit_response) { double(Intuit::Response, parse: {hey: 'derp'}) }

    before do
      Intuit::Request.stub(:new).and_return(intuit_request)
      Intuit::Response.stub(:new).and_return(intuit_response)
      ENCRYPTION.stub(:decrypt_and_verify).and_return(['default', 'yup'])
      intuit_update_request.stub(:update_request_record)
    end

    it 'decrypts the credentials' do
      ENCRYPTION.should_receive(:decrypt_and_verify).with('user_and_pw')

      intuit_update_request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
    end

    it 'makes a call to update the users mfa response in intuit' do
      Intuit::Request.should_receive(:new).with(1).and_return(intuit_request)
      intuit_request.should_receive(:update_mfa).
        with(4, '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82', ['default', 'yup'])

      intuit_update_request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
    end

    it 'it creates a new intuit response based on the return of the intuit request' do
      Intuit::Response.should_receive(:new).with({status_code: '200'}).and_return(double(parse: true))

      intuit_update_request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
    end

    it 'updates the request record' do
      intuit_account_request_record = double
      intuit_update_request.unstub(:update_request_record)

      ENCRYPTION.should_receive(:encrypt_and_sign).with("{\"hey\":\"derp\"}").and_return('encryption')
      Plink::IntuitAccountRequestRecord.should_receive(:find).with(482).and_return(intuit_account_request_record)
      intuit_account_request_record.should_receive(:update_attributes).with(processed: true, response: 'encryption')

      intuit_update_request.respond_to_mfa('user_and_pw', '26b5edd2-2dff-4225-8b39-ac36a19ba789', '10.136.17.82')
    end
  end
end
