require 'spec_helper'

describe OfferExpirationMailer do
  describe 'offer_removed_email' do
    it 'sends an email indicating that an offer has been automatically removed from a users wallet' do
      email = OfferExpirationMailer.offer_removed_email(
        first_name: 'Merlin',
        email: 'user@example.com',
        advertiser_name: 'wally world',
        user_token: 'abcde12345'
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == ['info@plink.com']
      email.subject.should == 'wally world has expired'
      email.header['X-SMTPAPI'].to_s.should == '{"category":["OfferExpirationMailer.offer_removed_email"]}'

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s
        body.should =~ /Great news - you've got an open wallet slot!/
        body.should =~ /Since the wally world offer just expired, you've got room in your Plink wallet for a new offer!/
        body.should =~ /Be a smarter shopper, fill your wallet \& maximize your Plink potential today!/
        body.should =~ /abcde12345/
      end
    end
  end
  describe 'offer_expiring_soon_email' do
    it 'sends an email indicating that an offer has been automatically removed from a users wallet' do
      email = OfferExpirationMailer.offer_expiring_soon_email(
        first_name: 'Merlin',
        email: 'user@example.com',
        end_date: 7.days.from_now,
        advertiser_name: 'wally world',
        user_token: 'abcde12345'
      ).deliver

      seven_days = 7.days.from_now
      email_end_date = seven_days.strftime("%A, %B #{seven_days.day.ordinalize}")

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == ['info@plink.com']
      email.subject.should == 'wally world has expired'
      email.header['X-SMTPAPI'].to_s.should == '{"category":["OfferExpirationMailer.offer_expiring_soon_email"]}'

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s
        body.should =~ /As a friendly reminder, the wally world offer will be expiring soon\./
        body.should =~ /Don't forget, go to wally world before #{email_end_date} and take advantage of the Plink Points you can earn with your purchase\./
        body.should =~ /#{email_end_date} will be the last day to earn Plink Points at wally world\./
        body.should =~ /abcde12345/
      end
    end
  end
end
 
