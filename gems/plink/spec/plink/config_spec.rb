require 'spec_helper'

describe Plink::Config do
  before(:each) do
    Plink::Config.instance.instance_variable_set(:@configured, false)
  end

  describe '#configure' do
    it 'should raise if called more than once' do
      Plink::Config.configure {}

      expect {
        Plink::Config.configure {}
      }.to raise_exception('Plink::Config#configure: cannot be called more than once')
    end

    it 'should raise unless given a block' do
      expect {
        Plink::Config.configure
      }.to raise_exception('Plink::Config#configure: no block given')
    end

    it 'is configurable via a block' do
      Plink::Config.configure do |config|
        config.image_base_url = 'http://www.example.com/image_base'
        config.card_add_url= 'http://www.example.com/card_add'
        config.card_change_url = 'http://www.example.com/card_change'
        config.card_reverify_url = 'http://www.example.com/card_reverify_url'
        config.mobile_registration_url = 'http://www.example.com/mobile_registration_url'
      end

      Plink::Config.instance.image_base_url.should == 'http://www.example.com/image_base'
      Plink::Config.instance.card_add_url.should == 'http://www.example.com/card_add'
      Plink::Config.instance.card_change_url.should == 'http://www.example.com/card_change'
      Plink::Config.instance.card_reverify_url.should == 'http://www.example.com/card_reverify_url'
      Plink::Config.instance.mobile_registration_url.should == 'http://www.example.com/mobile_registration_url'

    end
  end
end
