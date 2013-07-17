class PasswordResetMailer < ActionMailer::Base
  def instructions(email_address, first_name, token)
    @first_name = first_name
    @token = token

    mail(
      to: email_address,
      from: 'info@plink.com',
      subject: 'Plink: Password Reset Instructions'
    )
  end
end