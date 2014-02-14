class ContestMailer < PlinkMailer
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
    @contest_email = args[:contest_email]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: @contest_email.three_day_subject
    )
  end

  def winner_email(args)
    @contest_email = args[:contest_email]
    @contest_id = args[:contest_id]
    @email_address = args[:email]
    @first_name = args[:first_name]
    @user_id = args[:user_id]
    @user_token = args[:user_token]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: @contest_email.winner_subject
    )
  end
end
