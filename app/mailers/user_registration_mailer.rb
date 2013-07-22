class UserRegistrationMailer < ActionMailer::Base
  def welcome(args)
    @first_name = args.fetch(:first_name)

    mail(to: args.fetch(:email), from: 'info@plink.com')

  end
end