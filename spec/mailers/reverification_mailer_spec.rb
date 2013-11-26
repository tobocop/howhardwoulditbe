require 'spec_helper'

describe ReverificationMailer do
  describe 'notice_email' do
    it 'sends a reward notification email to the user' do
      email = ReverificationMailer.notice_email(
        {
          email: 'myshitisbroken@intuit.com',
          first_name: 'bobby',
          institution_name: 'my awesome bank',
          intuit_error_id: 103,
          reverification_link: 'this_is_fun',
          user_token: 'my_token'
        }
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['myshitisbroken@intuit.com']
      email.from.should == ['info@plink.com']
      email.subject.should == "Update Your Plink Account"

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s

        body.should =~ /Hey bobby/
        body.should =~ /We're unable to access your Plink account's transaction history - it looks like the username or password for your online bank account has changed\./
        body.should =~ /with your current my awesome bank login info./
        body.should =~ /this_is_fun/
      end
    end

    it 'sets the reverification link to the account page if passed in as nil' do
      email = ReverificationMailer.notice_email(
        {
          email: 'myshitisbroken@intuit.com',
          first_name: 'bobby',
          institution_name: 'my awesome bank',
          intuit_error_id: 103,
          reverification_link: nil,
          user_token: 'my_token'
        }
      ).deliver

      [email.html_part].each do |part|
        body = part.body.to_s

        body.should =~ /\/account\/login_from_email\?link_card=true&user_token=my_token/
      end
    end
  end
end

