require 'spec_helper'

describe Geoip::LocationLookup do
  describe '#by_ip' do
    let(:ip) { '209.120.212.22' }

    it 'looks up location by ip', :vcr do
      location = Geoip::LocationLookup.by_ip(ip)
      location[:state].should == 'CO'
      location[:city].should == 'Denver'
      location[:zip].should == '80222'
    end

    it 'it returns nil values if the http request fails' do
      http_double = double
      Net::HTTP.should_receive(:new).with('www.telize.com', 80).and_return(http_double)
      http_double.should_receive(:use_ssl=).with(false)
      http_double.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

      request_double = double
      Net::HTTP::Get.should_receive(:new).with("/geoip/#{ip}").and_return(request_double)
      http_double.should_receive(:request).with(request_double).and_raise

      location = Geoip::LocationLookup.by_ip(ip)
      location[:state].should be_nil
      location[:city].should be_nil
      location[:zip].should be_nil
    end
  end
end
