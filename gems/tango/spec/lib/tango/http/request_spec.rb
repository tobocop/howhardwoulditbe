require 'spec_helper'

describe Tango::Http::Request do
  describe 'post' do
    it 'sends an HTTP request to the given path with the given body' do
      Tango::Http::Request.new(Tango::Config.instance).post('/somewhere', 'foo=bar')
    end
  end
end
