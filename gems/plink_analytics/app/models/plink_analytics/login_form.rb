module PlinkAnalytics
  class LoginForm
    include ActiveModel::Validations
    include ActiveModel::Conversion

    attr_accessor :contact_record, :email, :password

    validates_presence_of :email, :password
    validate :contact_exists
    validate :authenticated

    def initialize(params = {})
      self.email = params[:email]
      self.password = params[:password]
    end

    def id
      contact_record.id
    end

  private

    def authenticated
      if contact_record && !contact_record.authenticate(password)
        errors.add(:password)
      end
    end

    def contact_exists
      self.contact_record = Plink::ContactRecord.find_by_email(email).first
      if !contact_record
        errors.add(:email)
      end
    end
  end
end
