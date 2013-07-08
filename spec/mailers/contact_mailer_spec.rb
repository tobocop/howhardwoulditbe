require 'spec_helper'

describe ContactMailer do
  describe 'create_contact_email' do
    it 'sends a contact email from the user' do
      email = ContactMailer.contact_email(
          {
              from: 'bob@example.com',
              category: 'sorcery',
              message_text: 'i like to magic',
              first_name: 'Merlin',
              last_name: 'Haggard'
          }
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == [Rails.application.config.contact_email_address]
      email.from.should == ['bob@example.com']
      email.subject.should == 'Contact Form: [sorcery]'

      [email.html_part, email.text_part].each do |part|
        body = Capybara.string(part.body.to_s)

        body.should have_content 'Message: i like to magic'
        body.should have_content 'Category: sorcery'
        body.should have_content 'First Name: Merlin'
        body.should have_content 'Last Name: Haggard'
      end
    end
  end
end
