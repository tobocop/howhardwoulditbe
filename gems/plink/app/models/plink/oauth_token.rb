module Plink
  class OauthToken < ActiveRecord::Base
    self.table_name = 'oauthTokens'

    alias_attribute :encrypted_oauth_token, :encryptedOauthToken
    alias_attribute :encrypted_oauth_token_secret, :encryptedOauthTokenSecret
    alias_attribute :oauth_token_iv, :oauthTokenIV
    alias_attribute :oauth_token_secret_iv, :oauthTokenSecretIV
    alias_attribute :user_id, :userID
    alias_attribute :is_active, :isActive

    attr_accessible :encrypted_oauth_token, :encrypted_oauth_token_secret, :oauth_token_iv, :oauth_token_secret_iv, :user_id, :is_active

    private

    def timestamp_attributes_for_create
      super << :created
    end

  end
end