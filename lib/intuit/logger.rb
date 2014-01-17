module Intuit
  class Logger

    def log_and_return_response(intuit_response, user_id, method_and_params)
      response = Marshal.load(Marshal.dump(intuit_response))
      message = log_message(response, user_id, method_and_params)

      Intuit.logger.info(message)

      intuit_response
    end

  private

    def log_message(response, user_id, method_and_params)
      time = Time.zone.now
      value = method_and_params.merge(user_id: user_id, response: sanitize(response))

      "[#{time} #{time.zone}] #{value}"
    end

    def sanitize(response)
      blacklisted_keys = [:account_number]

      blacklisted_keys.each do |key|
        recursive_delete(response, key)
      end

      response
    end

    def recursive_delete(hash, key_to_remove)
      # When Intuit responds with: JBoss Web/2.1.12.GA-patch-03 - Error report there may
      # be String keys present...
      return if hash.is_a?(String)

      hash.delete(key_to_remove)

      hash.each_value do |value_or_values|
        if value_or_values.is_a?(Hash)
          recursive_delete(value_or_values, key_to_remove)
        elsif value_or_values.is_a?(Array)
          value_or_values.each do |value|
            recursive_delete(value, key_to_remove)
          end
        end
      end
    end
  end
end


