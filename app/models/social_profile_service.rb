class SocialProfileService
  def self.get_users_social_profile(user_id)
    gigya_user_info = gigya_connection.get_user_info(user_id)
    Plink::UsersSocialProfileRecord.create(user_id: user_id, profile: gigya_user_info.json) if gigya_user_info.successful?
  end

private

  def self.gigya_connection
    @_gigya_connection ||= Gigya.new(Gigya::Config.instance)
  end
end
