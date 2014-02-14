require 'spec_helper'

describe RewardMailer do
  describe 'reward_notification_email' do
    it 'sends a reward notification email to the user' do
      award = double(award_display_name: 'herp', currency_award_amount: 2)

      email = RewardMailer.reward_notification_email(
        {
          email: 'spelling@joesspellingacademy.com',
          first_name: 'bert',
          user_token: 'my_token',
          user_currency_balance: 5,
          rewards: [award, award]
        }
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['spelling@joesspellingacademy.com']
      email.from.should == ['info@plink.com']
      email.subject.should == "You've just earned Plink Points!"
      email.header['X-SMTPAPI'].to_s.should == '{"category":["RewardMailer.reward_notification_email"]}'

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s

        body.should =~ /Hey bert/
        body.should =~ /You've just earned some Plink Points\. Nice work!/
        body.should =~ /2 Plink Points for herp/
        body.should =~ /Your current balance is/
        body.should =~ /5/
        body.should =~ /Plink Points\./
        body.should =~ /my_token/
      end
    end
  end
end
