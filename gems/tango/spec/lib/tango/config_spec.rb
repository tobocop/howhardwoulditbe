require 'spec_helper'

describe Tango::Config do

  before(:each) do
    Tango::Config.instance.instance_variable_set(:@configured, false)
  end

  describe '.configure' do
    it 'raise if called more than once' do
      Tango::Config.configure {}

      expect {
        Tango::Config.configure {}
      }.to raise_exception
    end

    it 'sets config options on the singleton config object' do
      Tango::Config.configure do |c|
        c.base_url = 'http://example.com/tango'
        c.username = 'user'
        c.password = 'pass'
      end

      Tango::Config.instance.base_url.should == 'http://example.com/tango'
      Tango::Config.instance.username.should == 'user'
      Tango::Config.instance.password.should == 'pass'
    end
  end
end
