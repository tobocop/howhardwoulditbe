module Plink
  class UsersSocialProfileRecord < ActiveRecord::Base
    self.table_name = 'users_social_profiles'

    attr_accessible :profile, :user_id

    def likes
      hashed_profile = JSON.parse(profile.gsub(/\r\n/,''))
      hashed_profile.has_key?('likes') ? hashed_profile['likes'] : []
    end
  end
end
