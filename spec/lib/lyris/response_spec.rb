require 'spec_helper'

describe Lyris::Response do
  let(:valid_response) {
    '<?xml version="1.0" encoding="iso-8859-1" ?><DATASET><TYPE>success</TYPE><DATA>978b2909bd</DATA></DATASET>'
  }

  let(:error_response) {
    '<?xml version="1.0" encoding="iso-8859-1" ?><DATASET><TYPE>error</TYPE><DATA>Can\'t find email address</DATA></DATASET>'
  }

  it 'parses the xml doc into a hash when initialized and stores it in a variable' do
    response = Lyris::Response.new(valid_response)
    response.lyris_response_hash.should be_present
  end

  describe '#successful?' do
    it 'returns true for a valid response' do
      response = Lyris::Response.new(valid_response)
      response.should be_successful
    end

    it 'returns false for an error response' do
      response = Lyris::Response.new(error_response)
      response.should_not be_successful
    end
  end

  describe '#data' do
    it 'returns the data attribute of a response' do
      response = Lyris::Response.new(valid_response)
      response.data.should == '978b2909bd'
    end
  end
end

