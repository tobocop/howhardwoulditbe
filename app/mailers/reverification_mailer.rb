class ReverificationMailer < PlinkMailer
  layout 'email_no_image'

  def notice_email(args)
    @email = args[:email]
    @explanation_message = args[:explanation_message]
    @first_name = args[:first_name]
    @html_link_message = args[:html_link_message]
    @preview_text = 'In order to continue earning Plink Points, your account needs to be updated'
    @text_link_message = args[:text_link_message]

    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: 'Update Your Plink Account'
    )
  end
end

