require 'spec_helper'

describe Tango::PurchaseCardResponse do

  let (:successful_response) {
    "{\"responseType\":\"SUCCESS\",\"response\":{\"referenceOrderId\":\"113-07253020-03\",\"cardToken\":\"51d45c37b74392.36662623\",\"cardNumber\":\"A931605\",\"cardPin\":null,\"redemptionUrl\":\"http:\\/\\/customer.ngcecodes.com\\/r\\/5610340555154657527318246715605277302367872338091722657228790059\",\"claimUrl\":\"http:\\/\\/customer.ngcecodes.com\\/r\\/5610340555154657527318246715605277302367872338091722657228790059\",\"challengeKey\":\"A931605\",\"eventNumber\":null}}"
  }

  let (:successful_raw_response) {
    {
      'responseType' => 'SUCCESS',
      'response' => {
        'referenceOrderId' => '113-07253020-03',
        'cardToken' => '51d45c37b74392.36662623',
        'cardNumber' => 'A931605',
        'cardPin' => nil,
        'redemptionUrl' => 'http://customer.ngcecodes.com/r/5610340555154657527318246715605277302367872338091722657228790059',
        'claimUrl' => 'http://customer.ngcecodes.com/r/5610340555154657527318246715605277302367872338091722657228790059',
        'challengeKey' => 'A931605',
        'eventNumber' => nil
      }
    }
  }

  let (:invalid_response) {
    "{\"responseType\":\"INV_INPUT\",\"response\":{\"invalid\":{\"body\":\"This method must be called with a POST body that contains valid JSON.\"}}}"
  }

  let(:invalid_raw_response) {
    {
      'responseType' => 'INV_INPUT',
      'response' => {
        'invalid' => {
          'body' => 'This method must be called with a POST body that contains valid JSON.'
        }
      }
    }
  }

  let(:unsuccessful_response) {
    "{\"responseType\":\"SYS_ERROR\",\"response\":{\"errorCode\":\"TPC:PC:35\"}}"
  }

  let(:unsuccessful_raw_response) {
    {
      'responseType' => 'SYS_ERROR',
      'response' => {
        'errorCode' => 'TPC:PC:35'
      }
    }
  }

  let (:malformed_response) { "This isn't JSON" }
  let (:blank_response) { '' }

  describe '.from_json' do
    it 'parses the successful json and creates a response from it' do
      response = Tango::PurchaseCardResponse.from_json(successful_response)

      response.response_type.should == 'SUCCESS'
      response.reference_order_id.should == '113-07253020-03'
      response.card_token.should == '51d45c37b74392.36662623'
      response.card_number.should == 'A931605'
      response.successful?.should == true
      response.raw_response.should == successful_raw_response
    end

    it 'parses the unsuccessful json and creates a response from it' do
      response = Tango::PurchaseCardResponse.from_json(unsuccessful_response)

      response.response_type.should == 'SYS_ERROR'
      response.successful?.should == false
      response.error_message.should == 'TPC:PC:35'
      response.raw_response.should == unsuccessful_raw_response
    end

    it 'creates a response if we submit invalid JSON to Tango' do
      response = Tango::PurchaseCardResponse.from_json(invalid_response)

      response.response_type.should == 'INV_INPUT'
      response.successful?.should == false
      response.error_message.should == 'This method must be called with a POST body that contains valid JSON.'
      response.raw_response.should == invalid_raw_response
    end

    it 'raises an exception if malformed JSON is received' do
      expect { Tango::PurchaseCardResponse.from_json(malformed_response) }.to raise_error()
    end

    it 'raises an exception if empty JSON is received' do
      expect { Tango::PurchaseCardResponse.from_json(blank_response) }.to raise_error()
    end
  end
end
