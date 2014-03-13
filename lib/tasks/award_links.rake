namespace :award_links do
  desc 'one time task to create the free award type and award link in the database for the welcome email link'
  task create_welcome_email_link: :environment do
    require 'base64'
    include Base64

    # url_value = Digest::SHA1.hexdigest 'welcome_email'
    award_type = Plink::AwardTypeRecord.create(
      dollar_amount: 0.05,
      award_code: 'welcome_email_incented_click',
      award_display_name: 'welcome_email_incented_click',
      award_type: 'welcome_email_incented_click',
      email_message: 'for clicking through our Welcome Email'
    )

    award_link = Plink::AwardLinkRecord.create(
      award_type_id: award_type.id,
      dollar_award_amount: 0.05,
      end_date: 100.years.from_now.to_date,
      is_active: true,
      name: 'Welcome email incented link',
      redirect_url: 'http://track.linkoffers.net/a.aspx?foid=22921872&fot=1001&foc=1',
      start_date: 1.day.ago.to_date
    )

    award_link.update_attribute('url_value', urlsafe_encode64(Digest::SHA1.hexdigest('welcome_email')))
  end
end
