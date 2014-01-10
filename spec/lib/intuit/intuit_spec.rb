require 'spec_helper'

describe Intuit do
  let(:logger) { double(:logger) }

  describe '#logger=' do
    it 'allows for a logger object to be set' do
      Intuit.should respond_to :logger=
    end
  end

  describe '#logger' do
    it 'returns the logger object' do
      Intuit.logger = logger

      Intuit.logger.should == logger
    end
  end
end
