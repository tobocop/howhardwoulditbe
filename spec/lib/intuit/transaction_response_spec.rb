require 'spec_helper'

describe Intuit::TransactionResponse do
  let(:raw_intuit_response) {
    {
      status_code: '200',
      result: {
        transaction_list: {
          credit_card_transaction: true
        }
      }
    }
  }

  subject(:transaction_response) { Intuit::TransactionResponse.new(raw_intuit_response) }

  it 'initializes with a raw intuit response' do
    transaction_response.raw_response.should == raw_intuit_response
  end

  describe '.to_h' do
    context 'when there are transactions' do
      it 'returns a hash without an error and transactions as true' do
        transaction_response.to_h.should == {error: false, transactions: true}
      end
    end

    context 'when there are no transactions' do
      let(:raw_intuit_response) {
        {
          status_code: '200',
          result: {
            transaction_list: {
              not_refreshed_reason: 'NOT_NECESSARY'
            }
          }
        }
      }

      it 'returns a hash with error true and a value of the correct message' do
        transaction_response.to_h.should == {error: true, :value=>"Account has no transactions."}
      end
    end
  end
end
