class UserRegistrationMailer < ActionMailer::Base
  def welcome(args)
    @first_name = args.fetch(:first_name)
    @virtual_currency_name = args.fetch(:virtual_currency_name)
    @email_address = args.fetch(:email)

    mail(to: @email_address,
         from: 'Plink <info@plink.com>',
         subject: 'Welcome to Plink'
    )
  end
end