module Lyris
  class UserService
    def self.add_to_lyris(user_id, email, currency_name)
      lyris_data = Lyris::UserDataCollector.new(user_id, currency_name)
      lyris_response = Lyris::User.new(Lyris::Config.instance, email, lyris_data.to_hash).add_to_list
      Rails.logger.debug(lyris_response.inspect)

      if !lyris_response.successful? && Rails.env.production?
        msg = "lyris_extensions#add_to_lyris failed for user_id: #{user_id}, email: #{email}, error #{lyris_response.data}"
        ::Exceptional::Catcher.handle(Exception.new(msg))
      end
    end
  end
end
