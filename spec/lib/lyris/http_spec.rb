require 'spec_helper'

describe Lyris::Http do
  let(:lyris_config) {Lyris::Config.instance}

  describe 'initialize' do
    it 'initializes with a lyris config' do
      lyris_http = Lyris::Http.new(lyris_config, 'type', 'activity', {})
      lyris_http.config.should == lyris_config
    end

    it 'initializes with a type string' do
      lyris_http = Lyris::Http.new(lyris_config, 'record', 'activity', {})
      lyris_http.type.should == 'record'
    end

    it 'initializes with an activity string' do
      lyris_http = Lyris::Http.new(lyris_config, 'type', 'update', {})
      lyris_http.activity.should == 'update'
    end

    it 'initializes with an options hash including email and additional xml' do
      lyris_http = Lyris::Http.new(lyris_config, 'type', 'activity', {email: 'test@test.com', additional_xml: 'xml'})
      lyris_http.email.should == 'test@test.com'
      lyris_http.additional_xml.should == 'xml'
    end
  end

  describe '.perform_request' do
    let(:lyris_http) {Lyris::Http.new(lyris_config, 'record', 'add', {email: 'test@test.com', additional_xml: 'xml'})}
    let(:valid_xml) {
      "<DATASET>\n        <SITE_ID>#{lyris_config.site_id}</SITE_ID>\n        <DATA type=\"extra\" id=\"password\">#{lyris_config.password}</DATA>\n        <MLID>#{lyris_config.mailing_list_id}</MLID>\n        <DATA type=\"email\">test@test.com</DATA>\n        xml\n      </DATASET>"
    }

    it 'sends the request to lyris' do
      http_double = double
      Net::HTTP.should_receive(:new).with('secure.elabs10.com', 443).and_return(http_double)
      http_double.should_receive(:use_ssl=).with(true)
      http_double.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_NONE)

      request_double = double
      Net::HTTP::Post.should_receive(:new).with(
        '/API/mailing_list.html?type=record&activity=add'
      ).and_return(request_double)
      request_double.should_receive(:set_form_data).with(input: valid_xml)

      http_double.should_receive(:request).with(request_double)

      lyris_http.perform_request
    end
  end
end

