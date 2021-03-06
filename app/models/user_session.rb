class UserSession
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :email, :password, :user

  validates :email, presence: true
  validates :password, presence: true

  def initialize(options = {})
    self.email = options[:email]
    self.password = options[:password]
  end

  def user_id
    user.id
  end

  def first_name
    user.first_name
  end

  def valid?
    is_valid = super

    if is_valid
      user = plink_user_service.find_by_email(email)

      if user.present?
        password_object = Plink::Password.new(unhashed_password: password, salt: user.salt)
        if password_object.hashed_value != user.password_hash
          errors.add(:base, 'Sorry, the email and password do not match for this account.  Please try again.')
        else
          self.user = user
        end
      else
        errors.add(:base, 'Sorry, the email and password do not match for this account.  Please try again.')
      end
    end

    errors.empty?
  end

  def persisted?
    false
  end

  private

  def plink_user_service
    Plink::UserService.new
  end
end
