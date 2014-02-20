class PlinkMailer < ActionMailer::Base
  default(
    from: 'Plink <info@plink.com>'
  )

  # See http://thepugautomatic.com/2012/08/sendgrid-metadata-and-rails/
  def initialize(method_name=nil, *args)
    super.tap do
      add_sendgrid_headers(method_name, args) if method_name
    end
  end

private

  def add_sendgrid_headers(action, args)
    mailer = self.class.name
    headers 'X-SMTPAPI' => {
      category: [ "#{mailer}.#{action}#{parse_additional_info(args)}" ]
    }.to_json
  end

  def parse_additional_info(args)
    return unless args[0].is_a?(Hash)

    additional_information =  args[0][:additional_category_information]
    ".#{additional_information}" if additional_information.present?
  end
end
