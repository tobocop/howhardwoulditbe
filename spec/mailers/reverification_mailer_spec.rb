require 'spec_helper'

describe ReverificationMailer do
  describe 'notice_email' do
    it 'sends a reward notification email to the user' do
      email = ReverificationMailer.notice_email(
        {
          email: 'myshitisbroken@intuit.com',
          explanation_message: 'Explain yourself!',
          first_name: 'bobby',
          html_link_message: 'with a link!',
          removal_date: 2.weeks.from_now.to_date,
          text_link_message: 'with a link!'
        }
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['myshitisbroken@intuit.com']
      email.from.should == ['info@plink.com']
      email.subject.should == "Update Your Plink Account"

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s

        body.should =~ /Hey bobby/
        body.should =~ /Explain yourself!/
        body.should =~ /with a link!/
        body.should =~ /If you do not complete the steps outlined above by #{2.weeks.from_now.to_date}, your account will be removed from Plink and you will no longer earn Plink Points./
      end
    end
  end
end

