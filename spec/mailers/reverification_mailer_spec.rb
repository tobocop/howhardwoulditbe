require 'spec_helper'

describe ReverificationMailer do
  describe 'notice_email' do
    it 'sends a reward notification email to the user' do
      email = ReverificationMailer.notice_email(
        {
          email: 'myshitisbroken@intuit.com',
          first_name: 'bobby',
          explanation_message: 'Explain yourself!',
          html_link_message: 'with a link!',
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
      end
    end
  end
end

