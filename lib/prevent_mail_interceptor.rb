class PreventMailInterceptor

  def self.delivering_email(message)
    unless deliver?(message)
      message.perform_deliveries = false
      Rails.logger.debug "Interceptor prevented sending mail #{message.inspect}!"
    end
  end

  def self.deliver?(message)
    true
  end
end

