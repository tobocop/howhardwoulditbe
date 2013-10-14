class OfferExpirationMailer < ActionMailer::Base
  default from: 'Plink <info@plink.com>', return_path: 'bounces@plink.com'

  def offer_removed_email(args)
    @advertiser_name = args[:advertiser_name]
    @email_address = args[:email]
    @first_name = args[:first_name]
    @user_token = args[:user_token]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: "#{@advertiser_name} has expired"
    )
  end

  def offer_expiring_soon_email(args)
    @advertiser_name = args[:advertiser_name]
    @email_address = args[:email]
    @end_date = args[:end_date].strftime("%A, %B #{args[:end_date].day.ordinalize}")
    @first_name = args[:first_name]
    @user_token = args[:user_token]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: "#{@advertiser_name} has expired"
    )
  end
end
