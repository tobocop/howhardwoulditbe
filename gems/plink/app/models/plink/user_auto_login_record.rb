module Plink
  class UserAutoLoginRecord < ActiveRecord::Base
    self.table_name = 'user_auto_logins'

    attr_accessible :expires_at, :user_id

    validates :user_id, presence: true

    validate :user_token_uniqueness

    scope :existing, ->(user_token) {
      where('expires_at > ?', Time.zone.now).where(user_token: user_token)
    }

    before_create { generate_token }

  private

    def user_token_uniqueness
      errors.add(:user_token) if self.class.existing(user_token).present?
    end

    def generate_token
      begin
        self[:user_token] = SecureRandom.urlsafe_base64(45)
      end while Plink::UserAutoLoginRecord.existing(self[:user_token]).present?
    end

  end
end
