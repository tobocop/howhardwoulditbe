require 'spec_helper'

describe Tango::Http::Request do
  describe 'post' do

    before do
      Artifice.activate_with ->(env) do
        request = Rack::Request.new(env)
        if request.path == '/somewhere'
          [200, {}, request.body.read]
        else
          [404, {}, 'Endpoint not found']
        end
      end
    end

    it 'sends an HTTP request to the given path with the given body' do
      my_request = Tango::Http::Request.new(Tango::Config.instance).post('/somewhere', 'foo=bar')
      my_request.body.should == "\"foo=bar\""
    end
  end
end
