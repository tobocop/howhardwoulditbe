module FeatureSpecHelper
  def delete_users_from_gigya
    auth_params = URI.encode_www_form(
        apiKey: Gigya::Config.instance.api_key,
        secret: Gigya::Config.instance.secret
    )

    User.all.each do |user|
      `/usr/bin/curl -s "https://socialize-api.gigya.com/socialize.deleteAccount?uid=#{user.id}&#{auth_params}"`
    end
  end
end
