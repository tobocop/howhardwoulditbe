class RewardMailer < ActionMailer::Base
  default from: 'Plink <info@plink.com>', return_path: 'bounces@plink.com'

  def reward_notification_email(args)
    @email_address = args[:email]
    @first_name = args[:first_name]
    @rewards = args[:rewards]
    @user_token = args[:user_token]
    @user_currency_balance = args[:user_currency_balance]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: t('application.rewards.emails.reward_notification_email.subject')
    )
  end
end
