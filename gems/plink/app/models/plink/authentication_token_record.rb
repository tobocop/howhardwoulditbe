module Plink
  class AuthenticationTokenRecord < ActiveRecord::Base
    self.table_name = 'authentication_tokens'

    attr_accessible :token, :user_id
  end
end
