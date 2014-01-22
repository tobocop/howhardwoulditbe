require 'spec_helper'

describe ContestMailer do
  describe 'daily_reminder_email' do
    let(:contest) { create_contest }
    let!(:contest_email) {
      create_contest_email(
        contest_id: contest.id,
        day_one_preview: 'sneak peak',
        day_one_subject: 'enter now enter now',
        day_one_body: 'daily reminder to enter this sweet contest',
        day_one_link_text: 'link to here',
        day_one_image: 'http://www.baconmockup.com/400/400'
      )
    }

    it 'sends a reminder to the user to enter the contest after' do
      email = ContestMailer.daily_reminder_email(
        first_name: 'Merlin',
        email: 'user@example.com',
        user_id: 2,
        contest_email: contest_email
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == ['info@plink.com']
      email.reply_to.should == ['support@plink.com']
      email.return_path.should == 'bounces@plink.com'
      email.subject.should == 'enter now enter now'

      [email.html_part, email.text_part].each do |part|
        body = Capybara.string(part.body.to_s)
        body.should have_content 'Hey Merlin'
        body.should have_content 'daily reminder to enter this sweet contest'
      end
    end
  end

  describe 'three_day_reminder_email' do
    let(:contest) { create_contest }
    let!(:contest_email) {
      create_contest_email(
        contest_id: contest.id,
        three_day_preview: 'sneak peak',
        three_day_subject: 'hurry up and enter sooooooon',
        three_day_body: 'three days time to enter',
        three_day_link_text: 'link to here',
        three_day_image: 'http://www.baconmockup.com/400/400'
      )
    }

    it 'sends a reminder to the user to enter the contest after' do
      email = ContestMailer.three_day_reminder_email(
        first_name: 'Merlin',
        email: 'user@example.com',
        user_id: 2,
        contest_email: contest_email
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == ['info@plink.com']
      email.reply_to.should == ['support@plink.com']
      email.return_path.should == 'bounces@plink.com'
      email.subject.should == 'hurry up and enter sooooooon'

      [email.html_part, email.text_part].each do |part|
        body = Capybara.string(part.body.to_s)
        body.should have_content 'Hey Merlin'
        body.should have_content 'three days time to enter'
      end
    end
  end

  describe 'winner_email' do
    let(:contest_email) {
      create_contest_email(
        contest_id: 1,
        winner_preview: 'sneak peak',
        winner_subject: 'you won congrats',
        winner_body: 'you won some stuff',
        winner_link_text: 'link to there',
        winner_image: 'http://www.baconmockup.com/400/400'
      )
    }

    it 'sends an email indicating that the person has won the contest' do
      email = ContestMailer.winner_email(
        contest_email: contest_email,
        contest_id: 1,
        email: 'user@example.com',
        first_name: 'Merlin',
        user_id: 2,
        user_token: 'abcde12345'
      ).deliver

      ActionMailer::Base.deliveries.count.should == 1

      email.to.should == ['user@example.com']
      email.from.should == ['info@plink.com']
      email.subject.should == 'you won congrats'

      [email.html_part, email.text_part].each do |part|
        body = part.body.to_s
        body.should have_content 'you won some stuff'
        body.should =~ /abcde12345/
      end
    end
  end
end
