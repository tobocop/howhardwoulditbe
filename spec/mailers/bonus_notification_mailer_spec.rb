require 'spec_helper'

describe BonusNotificationMailer do
  describe 'out_of_wallet_transaction_email' do
    it 'sends a notification that the user can earn bonus points by adding an offer to their wallet' do
      email = BonusNotificationMailer.out_of_wallet_transaction_email(
        first_name: 'jerry',
        email: 'seinfeld@newyork.com',
        advertiser_name: 'gap',
        max_plink_points: 1500,
        user_token: 'my_token'
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['seinfeld@newyork.com']
      email.from.should == ['info@plink.com']
      email.reply_to.should == ['support@plink.com']
      email.return_path.should == 'bounces@plink.com'
      email.subject.should == 'Get an easy 25 bonus points'
      email.header['X-SMTPAPI'].to_s.should == '{"category":["BonusNotificationMailer.out_of_wallet_transaction_email"]}'

      [email.text_part, email.html_part].each do |part|
        body = part.body.to_s

        body.should =~ /Hey jerry/
        body.should =~ /You're missing out!/
        body.should =~ /We noticed you visited gap but did not have the gap offer in your Plink Wallet\./
        body.should =~ /Add gap to your wallet within the next 72 hours and we'll give you/
        body.should =~ /25 Plink Points./
        body.should =~ /Then you'll be able to earn up to 1500 Plink Points on your next purchase at gap\./
        body.should =~ /my_token/
      end
    end
  end

  describe 'out_of_wallet_transaction_reminder_email' do
    it 'sends a notification that the user missed out on points by not having an offer in their waller' do
      email = BonusNotificationMailer.out_of_wallet_transaction_reminder_email(
        first_name: 'jerry',
        email: 'seinfeld@newyork.com',
        advertiser_name: 'gap',
        max_plink_points: 1500,
        user_token: 'my_token'
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['seinfeld@newyork.com']
      email.from.should == ['info@plink.com']
      email.reply_to.should == ['support@plink.com']
      email.return_path.should == 'bounces@plink.com'
      email.subject.should == 'You missed out on Plink Points'
      email.header['X-SMTPAPI'].to_s.should == '{"category":["BonusNotificationMailer.out_of_wallet_transaction_reminder_email"]}'

      [email.text_part, email.html_part].each do |part|
        body = part.body.to_s

        body.should =~ /Hey jerry/
        body.should =~ /You're missing out!/
        body.should =~ /We noticed you visited gap but did not have the gap offer in your Plink Wallet\./
        body.should =~ /Add gap to your wallet to earn up to 1500 Plink Points on your next purchase at gap\./
        body.should =~ /my_token/
      end
    end
  end
end

