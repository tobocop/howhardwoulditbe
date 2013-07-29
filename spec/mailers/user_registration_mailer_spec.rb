require 'spec_helper'

describe UserRegistrationMailer do
  describe '#welcome' do
    it 'sends a welcome email to the user' do
      email = UserRegistrationMailer.welcome(first_name: 'Jub', email: 'jobo@example.com', virtual_currency_name: 'Plonk Points')

      email.to.should == ['jobo@example.com']
      email.header['From'].to_s.should == 'Plink <info@plink.com>'
      email.subject.should == 'Welcome to Plink'

      [email.html_part, email.text_part].each do |email_part|
        email_string = Capybara.string(email_part.body.to_s)

        email_string.should have_content 'Hi Jub'
        email_string.should have_content 'Welcome and thanks for signing up for Plink'
        email_string.should have_content "We're excited to help you earn Plonk Points"
      end
    end
  end
end
