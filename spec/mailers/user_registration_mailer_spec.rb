require 'spec_helper'

describe UserRegistrationMailer do
  describe '#welcome' do
    it 'sends a welcome email to the user' do
      email = UserRegistrationMailer.welcome(first_name: 'Jub', email: 'jobo@example.com', virtual_currency_name: 'Plonk Points')

      email.to.should == ['jobo@example.com']
      email.header['From'].to_s.should == 'Plink <info@plink.com>'
      email.subject.should == 'Welcome to Plink'
      email.header['X-SMTPAPI'].to_s.should == '{"category":["UserRegistrationMailer.welcome"]}'

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
      email = UserRegistrationMailer.complete_registration(first_name: 'Jub', email: 'jobo@example.com', user_id: 3)

      email.to.should == ['jobo@example.com']
      email.header['From'].to_s.should == 'Plink <info@plink.com>'
      email.subject.should == 'Get Double Plink Points Through May 31, 2014'
      email.header['X-SMTPAPI'].to_s.should == '{"category":["UserRegistrationMailer.complete_registration"]}'

      [email.html_part, email.text_part].each do |email_part|
        email_string = Capybara.string(email_part.body.to_s)

        email_string.should have_content 'Hey Jub'
        email_string.should have_content 'Thanks for signing up for Plink! You just need to link a credit or debit card to your Plink account to start earning rewards.'
        email_string.should have_content 'All Plink members who link a Barclaycard Arrival World MasterCard'
        email_string.should have_content 'to their Plink account, get *DOUBLE PLINK POINTS now through May 31, 2014!'
        email_string.should have_content 'Activate your DOUBLE PLINK POINTS offer'
        email_string.should have_content 'When you link a Barclaycard Arrival World MasterCard'
        email_string.should have_content 'to your Plink account we\'ll give you *DOUBLE PLINK POINTS through May 31, 2014! That\'s up to $15.00 in Plink Points for a single visit at some of our participating locations.'
        email_string.should have_content '*Double Plink Points are only awarded by clicking through this email and linking a Barclaycard Arrival World MasterCard'
        email_string.should have_content 'to your Plink account between 3/12/14 and 5/31/14.  Double Plink Points are only awarded on the base point value for ^qualifying Plink purchases. Double Plink Points will not be awarded for bonus point promotions. Plink Points may take up to 5 business days to appear in your Plink account.'
        email_string.should have_content '^A purchase is considered qualified when the merchant is in your Plink Wallet and meets the minimum purchase price.'
      end
    end
  end
end
