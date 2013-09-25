class ContestMailer < ActionMailer::Base

  default from: 'info@plink.com', return_path: 'bounces@plink.com'

  def daily_reminder_email(args)
    @first_name = args[:first_name]
    @user_id = args[:user_id]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: 'Enter Today - $1,000 Up For Grabs'
    )
  end

  def three_day_reminder_email(args)
    @first_name = args[:first_name]
    @user_id = args[:user_id]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: 'Your $1,000 entries expire today'
    )
  end
end
