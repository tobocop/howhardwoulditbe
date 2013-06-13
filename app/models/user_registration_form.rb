class UserRegistrationForm
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  VALID_EMAIL_REGEXP = /
    ^[^+]+             # One or more not '+' signs
    @                  # @ sign is mandatory
    .+                 # One or more characters
    \.                 # A literal dot
    .+                 # One or more characters
    $/x

  attr_accessor :unhashed_password, :unhashed_password_confirmation, :first_name, :email, :user

  validates :unhashed_password, length: {minimum: 6}, confirmation: true
  validates :email, format: {with: VALID_EMAIL_REGEXP, allow_blank: true} # presence validation occurs in User model
  validate :params_are_valid_for_user

  def initialize(options = {})
    self.first_name = options[:first_name]
    self.email = options[:email]
    self.unhashed_password = options[:unhashed_password]
    self.unhashed_password_confirmation = options[:unhashed_password_confirmation]
  end

  def save
    return unless valid?
    user.save
  end

  def persisted?
    false
  end

  private

  def params_are_valid_for_user
    self.user = User.new(user_params)
    if !user.valid?
      user.errors.each do |attr, message|
        errors.add(attr, message)
      end
    end
  end

  def user_params
    password = hashed_password
    {
        :first_name => first_name,
        :email => email,
        :password => password.hashed_value,
        :salt => password.salt
    }
  end

  def hashed_password
    Password.new(unhashed_password: unhashed_password)
  end
end