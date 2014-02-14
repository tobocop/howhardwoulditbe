require 'spec_helper'

describe PromotionalWalletItemMailer do
  describe '#unlock_promotional_wallet_item_email' do
    it 'sends an email indicating that wallet slot has been unlocked because of a promotion' do
      email = PromotionalWalletItemMailer.unlock_promotional_wallet_item_email(
        first_name: 'Archibald',
        email: 'archie.leach@example.com',
        user_token: 'abcde12345'
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['archie.leach@example.com']
      email.from.should == ['info@plink.com']
      email.subject.should == "You've unlocked an extra wallet slot"
      email.header['X-SMTPAPI'].to_s.should == '{"category":["PromotionalWalletItemMailer.unlock_promotional_wallet_item_email"]}'

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s
        body.should =~ /Hey Archibald/
        body.should =~ /Congratulations! You've unlocked a new wallet slot\./
        body.should =~ /Be a smarter shopper, fill your wallet &(:?amp;)? maximize your Plink potential today!/
        body.should =~ /abcde12345/
      end
    end
  end
end