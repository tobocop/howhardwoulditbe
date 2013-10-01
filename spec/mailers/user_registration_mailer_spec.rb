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

  describe '#complete_registration' do
    it 'sends a reminder email to the user to link a card' do
      email = UserRegistrationMailer.complete_registration(first_name: 'Jub', email: 'jobo@example.com')

      email.to.should == ['jobo@example.com']
      email.header['From'].to_s.should == 'Plink <info@plink.com>'
      email.subject.should == 'Important Account Information - Your registration is incomplete'

      [email.html_part, email.text_part].each do |email_part|
        email_string = Capybara.string(email_part.body.to_s)

        email_string.should have_content 'Hey Jub'
        email_string.should have_content 'Thanks for signing up for Plink! You just need to link a credit or debit card to your Plink account to finish registration.'
        email_string.should have_content 'Once you link a credit/debit card you can start earning Plink Points which can be redeemed for gift cards from places like Amazon.com, Starbucks, Walmart, Target, Subway, and more.'
        email_string.should have_content 'What are you waiting for? Be a smarter shopper and get the rewards you deserve for dining and shopping at over 75,000 locations!'
      end
    end
  end
end
