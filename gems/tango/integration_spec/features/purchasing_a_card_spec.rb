require 'spec_helper'

describe 'Purchasing a card' do
  it 'sends a request to Tango and create a card to send to the user' do
    response = Tango::CardService.new(Tango::Config.instance).purchase(card_sku:'tango-card', card_value: 500.0, recipient_name:'hunter', tango_sends_email: true,  recipient_email: 'fake@example.com', gift_message: 'awesome message', gift_from: 'us')
    response.should be_a(Tango::PurchaseCardResponse)
    response.should be_successful
  end
end
