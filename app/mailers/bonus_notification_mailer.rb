class BonusNotificationMailer < ActionMailer::Base
  default from: 'Plink <info@plink.com>', return_path: 'bounces@plink.com'

  def out_of_wallet_transaction_email(args)
    @first_name = args[:first_name]
    @email = args[:email]
    @advertiser_name = args[:advertiser_name]
    @max_plink_points = args[:max_plink_points]
    @user_token = args[:user_token]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: 'Get an easy 25 bonus points'
    )
  end

  def out_of_wallet_transaction_reminder_email(args)
    @first_name = args[:first_name]
    @email = args[:email]
    @advertiser_name = args[:advertiser_name]
    @max_plink_points = args[:max_plink_points]
    @user_token = args[:user_token]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: 'You missed out on Plink Points'
    )
  end
end
