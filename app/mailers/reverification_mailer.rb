class ReverificationMailer < PlinkMailer
  layout 'email_no_image'

  def notice_email(args)
    @email = args[:email]
    @first_name = args[:first_name]
    @institution_name = args[:institution_name]

    reverification_link = args[:reverification_link].nil? ? login_from_email_account_url(user_token: args[:user_token], link_card: true) : args[:reverification_link]

    if args[:notice_type] == 'three_day_reminder'
      base = 'application.intuit_error_messages.emails.three_day_reminder.error_' + args[:intuit_error_id].to_s
    else
      base = 'application.intuit_error_messages.emails.initial_notice.error_' + args[:intuit_error_id].to_s
    end

    interpolated_params = {
      institution_name: @institution_name,
      reverification_link: reverification_link
    }
    @explanation_message = t(base + '.explanation_message')
    @html_link_message = t(base + '.html_link_message', interpolated_params)
    @text_link_message = t(base + '.text_link_message', interpolated_params)

    @preview_text = 'In order to continue earning Plink Points, your account needs to be updated'
    mail(
      to: args[:email],
      reply_to: 'support@plink.com',
      subject: 'Update Your Plink Account'
    )
  end
end

