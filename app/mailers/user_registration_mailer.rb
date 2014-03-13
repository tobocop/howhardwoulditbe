class UserRegistrationMailer < PlinkMailer
  def welcome(args)
    @first_name = args.fetch(:first_name)
    @virtual_currency_name = args.fetch(:virtual_currency_name)
    @email_address = args.fetch(:email)

    mail(
      to: @email_address,
      subject: 'Welcome to Plink'
    )
  end

  def complete_registration(args)
    @first_name = args.fetch(:first_name)
    @email_address = args.fetch(:email)
    @user_id = args.fetch(:user_id)

    mail(
      to: @email_address,
      subject: 'Get Double Plink Points Through May 31, 2014'
    )
  end
end
