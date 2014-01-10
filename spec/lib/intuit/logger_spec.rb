require 'spec_helper'

describe Intuit::Logger do
  let(:logger) { double(:logger) }

  before { Intuit.stub(:logger).and_return(logger) }

  describe '#log_and_return_response' do
    it 'calls the configured logger' do
      logger.should_receive(:info).with(/my_method/)

      Intuit::Logger.new.log_and_return_response({foo: 'bar'}, 13, {method: 'my_method', params: {}})
    end

    it 'returns the response parameter' do
      logger.stub(:info)
      response = {text: 'best response of all time', account_number: '1234'}

      Intuit::Logger.new.log_and_return_response(response, 13, {}).should == response
    end

    it 'sanitizes account_number when logging' do
      response = {text: 'best response of all time', account_number: '1234', stuff: {account_number: '5678'}}

      logger.should_not_receive(:info).with(/1234/)
      logger.should_not_receive(:info).with(/5678/)

      Intuit::Logger.new.log_and_return_response(response, 13, {})
    end
  end
end
