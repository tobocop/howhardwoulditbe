require 'spec_helper'

describe Tango::CardService do

  subject { Tango::CardService.new(Tango::Config.instance) }

  describe '#purchase' do
    it 'calls tango card to send a gift card' do
      Tango::Http::Request.any_instance.should_receive(:post) do |arg1, options|
        arg1.should == '/Version2/PurchaseCard'
        options[:username].should == 'third_party_int@tangocard.com'
        options[:password].should == 'integrateme'
        options[:cardSku].should == 'walmart-gift-card'
        options[:cardValue].to_s.should == '500'
        options[:tcSend].should == true
        options[:recipientName].should == 'aname'
        options[:recipientEmail].should == 'hunter@example.com'
        options[:giftMessage].should == 'Your test worked!'
        options[:giftFrom].should == 'Plink'
      end.and_return(mock('response', body: 'response'))

      Tango::PurchaseCardResponse.should_receive(:from_json).with('response').and_return('tahngo response')

      response = subject.purchase(
        {
          card_sku: 'walmart-gift-card',
          card_value: 500.0,
          tango_sends_email: true,
          recipient_name: 'aname',
          recipient_email: 'hunter@example.com',
          gift_message: 'Your test worked!',
          gift_from: 'Plink'
        }
      )

      response.should == 'tahngo response'
    end
  end
end
