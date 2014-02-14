class PlinkMailer < ActionMailer::Base
  default(
    from: 'Plink <info@plink.com>'
  )

  # See http://thepugautomatic.com/2012/08/sendgrid-metadata-and-rails/
  def initialize(method_name=nil, *args)
    super.tap do
      add_sendgrid_headers(method_name) if method_name
    end
  end

private

  def add_sendgrid_headers(action)
    mailer = self.class.name
    headers 'X-SMTPAPI' => {
      category: [ "#{mailer}.#{action}" ]
    }.to_json
  end
end