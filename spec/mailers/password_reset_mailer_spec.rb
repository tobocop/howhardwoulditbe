require 'spec_helper'

describe PasswordResetMailer do
  describe 'instructions' do
    it 'sends a password reset email to the supplied email address' do
      email = PasswordResetMailer.instructions('bob@example.com', 'Bob').deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['bob@example.com']
      email.from.should == ['info@plink.com']
      email.subject.should == 'Plink: Password Reset Instructions'

      [email.html_part, email.text_part].each do |part|
        body = Capybara.string(part.body.to_s)

        body.should have_content 'Hi Bob,'
      end
    end
  end
end
