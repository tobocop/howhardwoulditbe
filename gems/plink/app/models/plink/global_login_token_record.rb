module Plink
  class GlobalLoginTokenRecord < ActiveRecord::Base
    self.table_name = 'global_login_tokens'

    attr_accessible :expires_at, :redirect_url
    validate :expires_before_fifteenth_day
    validate :global_token_uniqueness

    scope :existing, ->(token) {
      where('expires_at > ?', Time.zone.now).where(token: token)
    }

    before_create { generate_token }

  private

    def expires_before_fifteenth_day
      errors.add(:expires_at) if expires_at > 15.days.from_now.to_date
    end

    def global_token_uniqueness
      errors.add(:token) if self.class.existing(token).present?
    end

    def generate_token
      begin
        self[:token] = SecureRandom.urlsafe_base64(45)
      end while Plink::GlobalLoginTokenRecord.existing(self[:token]).present?
    end
  end
end
