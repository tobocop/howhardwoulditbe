class UserSession
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :email, :password, :user

  validates :email, :password, presence: true

  def initialize(options = {})
    self.email = options[:email]
    self.password = options[:password]
  end

  def valid?
    is_valid = super

    if is_valid
      user = User.find_by_email(email)

      if user.present?
        password_object = Password.new(unhashed_password: password, salt: user.salt)
        if password_object.hashed_value != user.password_hash
          errors.add(:email, 'or password is invalid')
        else
          self.user = user
        end
      else
        errors.add(:email, 'or password is invalid')
      end
    end

    errors.empty?
  end

  def persisted?
    false
  end
end