module Plink
  class UsersSocialProfileRecord < ActiveRecord::Base
    self.table_name = 'users_social_profiles'

    attr_accessible :profile, :user_id
  end
end
