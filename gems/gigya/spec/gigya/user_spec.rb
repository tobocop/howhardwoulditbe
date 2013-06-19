require 'spec_helper'

describe Gigya::User do
  describe 'initialization' do
    it 'has an email' do
      user = Gigya::User.new(email: 'bob@example.com')
      user.email.should == 'bob@example.com'
    end

    it 'has a first name' do
      user = Gigya::User.new(firstName: 'Bob')
      user.first_name.should == 'Bob'
    end

    it 'has an id' do
      user = Gigya::User.new(UID: 123)
      user.id.should == 123
    end

    it 'knows if it is a site user' do
      user = Gigya::User.new(isSiteUser: true)
      user.should be_site_user
    end
  end

  describe '.from_redirect_params' do
    let(:valid_params) { {UIDSignature: 'good_signature'} }

    it 'should return a Gigya user if the params are valid' do
      signature_stub = stub(:valid? => true)
      Gigya::Signature.stub(:new).with(valid_params) { signature_stub }
      Gigya::User.from_redirect_params(valid_params).should be_a(Gigya::User)
    end

    it 'should raise an exception if signature does not match request params' do
      params = {UIDSignature: 'bad_signature'}
      signature_stub = stub(:valid? => false)
      Gigya::Signature.stub(:new).with(params) { signature_stub }
      Gigya::User.from_redirect_params(params).should_not be
    end
  end
end
