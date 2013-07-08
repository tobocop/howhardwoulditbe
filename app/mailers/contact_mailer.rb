class ContactMailer < ActionMailer::Base

  default to: 'contactus@plink.com'

  def contact_email(args)

    @message_text = args[:message_text]
    @category = args[:category]
    @first_name = args[:first_name]
    @last_name = args[:last_name]

    mail(
        from: args[:from],
        subject: "Contact Form: [#{args[:category]}]"
    )
  end

end