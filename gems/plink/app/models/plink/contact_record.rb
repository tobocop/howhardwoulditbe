module Plink
  class ContactRecord < ActiveRecord::Base
    self.table_name = 'contacts'
    has_secure_password

    attr_accessible :brand_id, :email, :first_name, :is_active, :last_name,
      :password, :password_confirmation

    belongs_to :brand, class_name: 'Plink::BrandRecord'

    validates_presence_of :brand_id, :email, :first_name, :last_name
    validates_uniqueness_of :email

    scope :find_by_email, ->(email) {
      where(email: email)
    }

    before_validation :set_password_if_not_present

  private

    def set_password_if_not_present
      if !password.present?
        self.password = SecureRandom.uuid
        self.password_confirmation = password
      end
    end
  end
end
