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

  attr_accessor :password, :password_confirmation, :first_name, :email, :user_creation_service, :user

  validates :password, length: {minimum: 6, message: 'Please enter a password at least 6 characters long'}, confirmation: {message: 'Confirmation password doesn\'t match', if: Proc.new { password_confirmation.present? }}
  validates :password_confirmation, presence: {message: 'Please confirm your password'}
  validates :email, format: {with: VALID_EMAIL_REGEXP, allow_blank: true, message: 'Please enter a valid email address'}
  validate :params_are_valid_for_user

  def initialize(options = {})
    self.first_name = options[:first_name]
    self.email = options[:email]
    self.password = options[:password]
    self.password_confirmation = options[:password_confirmation]
  end

  def save
    return unless valid?
    self.user = user_creation_service.create_user
    true
  end

  def persisted?
    false
  end

  def user_id
    user_creation_service.user_id
  end

  private

  def params_are_valid_for_user
    self.user_creation_service = Plink::UserCreationService.new(user_params)
    if !user_creation_service.valid?
      user_creation_service.errors.each do |attr, message|
        errors.add(attr, message)
      end
    end
  end

  def user_params
    password = hashed_password
    {
        :first_name => first_name,
        :email => email,
        :password_hash => password.hashed_value,
        :salt => password.salt
    }
  end

  def hashed_password
    Password.new(unhashed_password: password)
  end
end
