class UserRegistrationMailer < PlinkMailer
  def welcome(args)
    @first_name = args.fetch(:first_name)
    @virtual_currency_name = args.fetch(:virtual_currency_name)
    @email_address = args.fetch(:email)

    mail(to: @email_address,
         subject: 'Welcome to Plink'
    )
  end
end