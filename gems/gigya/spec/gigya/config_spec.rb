require 'spec_helper'

describe Gigya::Config do
  before(:each) do
    Gigya::Config.instance.instance_variable_set(:@configured, false)
  end

  describe '#configure' do
    it 'should raise if called more than once' do
      Gigya::Config.configure {}

      expect {
        Gigya::Config.configure {}
      }.to raise_exception('Gigya::Config#configure: cannot be called more than once')
    end

    it 'should raise unless given a block' do
      expect {
        Gigya::Config.configure
      }.to raise_exception('Gigya::Config#configure: no block given')
    end

    it 'is configurable via a block' do
      Gigya::Config.configure do |config|
        config.api_key = '1234'
        config.secret = 'my-secret'
        config.registration_redirect_base_url = 'http://example.com:9000'
      end

      Gigya::Config.instance.api_key.should == '1234'
      Gigya::Config.instance.secret.should == 'my-secret'
      Gigya::Config.instance.registration_redirect_base_url.should == 'http://example.com:9000'
    end
  end
end
