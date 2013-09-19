require 'spec_helper'

describe ContestMailer do
  describe 'daily_reminder_email' do
    it 'sends a reminder to the user to enter the contest after' do

      email = ContestMailer.daily_reminder_email(
        first_name: 'Merlin',
        email: 'user@example.com',
        user_id: 2
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == [Rails.application.config.contact_email_address]
      email.subject.should == 'Enter Today - $1,000 Up For Grabs'

      [email.html_part, email.text_part].each do |part|
        body = Capybara.string(part.body.to_s)
        body.should have_content 'Hey Merlin'
        body.should have_content 'Score even more entries when you share on Facebook and Twitter. Enter everyday to increase your chances of winning.'
      end
    end
  end

  describe 'three_day_reminder_email' do
    it 'sends a reminder to the user to enter the contest after' do

      email = ContestMailer.three_day_reminder_email(
        first_name: 'Merlin',
        email: 'user@example.com',
        user_id: 2
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == [Rails.application.config.contact_email_address]
      email.subject.should == 'Your $1,000 entries expire today'

      [email.html_part, email.text_part].each do |part|
        body = Capybara.string(part.body.to_s)
        body.should have_content 'Hey Merlin'
        body.should have_content "It's been a few days since you've entered our contest. Enter daily to increase your chances of winning."
      end
    end
  end
end
