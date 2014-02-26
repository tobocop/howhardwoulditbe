Griddler.configure do |config|
   config.processor_class = PlinkApi::V1::EmailProcessor
   config.email_service = :sendgrid
end
