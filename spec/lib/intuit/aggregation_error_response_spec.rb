require 'spec_helper'

describe Intuit::AggregationErrorResponse do
  subject(:aggregation_error_response) do
    Intuit::AggregationErrorResponse.new('much error')
  end

  describe '#intialize' do
    it 'initializes with an error message' do
      aggregation_error_response.error_message.should == 'much error'
    end
  end

  describe '#parse' do
    it 'returns that there is an error and what the messsage is' do
      aggregation_error_response.parse.should == {
        error: true,
        value: 'much error'
      }
    end
  end
end
