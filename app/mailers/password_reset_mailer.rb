class PasswordResetMailer < PlinkMailer
  def instructions(email_address, first_name, token)
    @first_name = first_name
    @token = token
    @email_address = email_address

    mail(
      to: @email_address,
      subject: 'Plink: Password Reset Instructions'
    )
  end
end