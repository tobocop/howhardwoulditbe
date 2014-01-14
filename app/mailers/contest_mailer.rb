class ContestMailer < ActionMailer::Base
  default from: 'Plink <info@plink.com>', return_path: 'bounces@plink.com'

  def daily_reminder_email(args)
    @first_name = args[:first_name]
    @user_id = args[:user_id]
    @contest_email = args[:contest_email]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: @contest_email.day_one_subject
    )
  end

  def three_day_reminder_email(args)
    @first_name = args[:first_name]
    @user_id = args[:user_id]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: t('application.contests.emails.three_day_reminder_email.subject')
    )
  end

  def winner_email(args)
    @contest_id = args[:contest_id]
    @email_address = args[:email]
    @first_name = args[:first_name]
    @user_id = args[:user_id]
    @user_token = args[:user_token]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: t('application.contests.emails.winner_email.subject')
    )
  end
end
