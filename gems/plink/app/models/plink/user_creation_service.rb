module Plink
  class UserCreationService

    attr_accessor :avatar_thumbnail_url, :email, :first_name, :password_hash, :salt, :avatar_thumbnail_url, :user

    def initialize(options = {})
      self.email = options.fetch(:email)
      self.first_name = options.fetch(:first_name)
      self.password_hash = options.fetch(:password_hash)
      self.salt = options.fetch(:salt)
      self.avatar_thumbnail_url = options.fetch(:avatar_thumbnail_url, nil)

      set_user
    end

    def create_user
      Plink::User.transaction do
        user.save
        Plink::WalletCreationService.new(user_id: user_id).create_for_user_id
        user
      end
    end

    def valid?
      user.valid?
    end

    def errors
      user.errors
    end

    def user_id
      user.id
    end

    private

    def set_user
      self.user = Plink::User.new(email: self.email, first_name: self.first_name, password_hash: self.password_hash, salt: self.salt, avatar_thumbnail_url: self.avatar_thumbnail_url)
    end


  end
end