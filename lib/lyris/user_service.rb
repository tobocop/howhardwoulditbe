module Lyris
  class UserService
    def self.add_to_lyris(user_id, email, currency_name)
      lyris_data = Lyris::UserDataCollector.new(user_id, currency_name)
      lyris_response = Lyris::User.new(lyris_config, email, lyris_data.to_hash).add_to_list

      if !lyris_response.successful? && Rails.env.production?
        msg = "lyris_extensions#add_to_lyris failed for user_id: #{user_id}, email: #{email}, error #{lyris_response.data}"
        ::Exceptional::Catcher.handle(Exception.new(msg))
      end
    end

    def self.update_users_email(old_email, new_email)
      lyris_response = Lyris::User.new(lyris_config, old_email, {new_email: new_email}).update_email

      if !lyris_response.successful? && Rails.env.production?
        msg = "lyris_extensions#update_email failed for old_email: #{old_email}, email: #{new_email}, error #{lyris_response.data}"
        ::Exceptional::Catcher.handle(Exception.new(msg))
      end
    end

  private

    def self.lyris_config
      Lyris::Config.instance
    end
  end
end
