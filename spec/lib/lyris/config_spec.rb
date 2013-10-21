require 'spec_helper'

describe Lyris::Config do
  before(:each) do
    Lyris::Config.instance.instance_variable_set(:@configured, false)
  end

  describe '#configure' do
    it 'should raise if called more than once' do
      Lyris::Config.configure {}

      expect {
        Lyris::Config.configure {}
      }.to raise_exception('Lyris::Config#configure: cannot be called more than once')
    end

    it 'should raise unless given a block' do
      expect {
        Lyris::Config.configure
      }.to raise_exception('Lyris::Config#configure: no block given')
    end

    it 'is configurable via a block' do
      Lyris::Config.configure do |config|
        config.site_id = 1234
        config.password = 'my-secret'
        config.mailing_list_id = 238947
      end

      Lyris::Config.instance.site_id.should == 1234
      Lyris::Config.instance.password.should == 'my-secret'
      Lyris::Config.instance.mailing_list_id.should == 238947
    end
  end
end
