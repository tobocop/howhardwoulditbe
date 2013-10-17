class PromotionalWalletItemMailer < ActionMailer::Base
  default from: 'Plink <info@plink.com>', return_path: 'bounces@plink.com'

  def unlock_promotional_wallet_item_email(args)
    @email_address = args[:email]
    @first_name = args[:first_name]
    @user_token = args[:user_token]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: "You've unlocked an extra wallet slot"
    )
  end
end