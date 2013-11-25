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
      email.from.should == ['info@plink.com']
      email.reply_to.should == ['support@plink.com']
      email.return_path.should == 'bounces@plink.com'
      email.subject.should == 'Enter Today - Apple iPad Up For Grabs'

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
      email.from.should == ['info@plink.com']
      email.reply_to.should == ['support@plink.com']
      email.return_path.should == 'bounces@plink.com'
      email.subject.should == 'Your iPad Giveaway entries expire today'

      [email.html_part, email.text_part].each do |part|
        body = Capybara.string(part.body.to_s)
        body.should have_content 'Hey Merlin'
        body.should have_content "It's been a few days since you've entered our contest. Enter daily to increase your chances of winning."
      end
    end
  end

  describe 'winner_email' do
    it 'sends an email indicating that the person has won the contest' do
      email = ContestMailer.winner_email(
        first_name: 'Merlin',
        email: 'user@example.com',
        user_id: 2,
        contest_id: 1,
        user_token: 'abcde12345'
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == ['info@plink.com']
      email.subject.should == "Plink's iPad Holiday Giveaway Winners Announced!! See if you won!"

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s
        body.should =~ /Plink's iPad Holiday Giveaway has ended\.\.\./
        body.should =~ /Congratulations - You've won a prize in Plink's iPad Holiday Giveaway! Did you win the Apple iPad 2\?/
        body.should =~ /abcde12345/
      end
    end
  end
end
