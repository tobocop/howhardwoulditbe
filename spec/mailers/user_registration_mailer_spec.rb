require 'spec_helper'

describe UserRegistrationMailer do
  describe '#welcome' do
    it 'sends a welcome email to the user' do
      email = UserRegistrationMailer.welcome(first_name: 'Jub', email: 'jobo@example.com')

      email.to.should == ['jobo@example.com']
      email.from.should == ['info@plink.com']

      [email.html_part, email.text_part].each do |email_part|
        email_string = Capybara.string(email_part.body.to_s)

        email_string.should have_content 'Welcome to Plink'
      end
    end
  end
end
