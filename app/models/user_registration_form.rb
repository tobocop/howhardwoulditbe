class UserRegistrationForm
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :email, :first_name, :password, :password_confirmation,
    :provider, :user, :user_creation_service, :virtual_currency_name, :ip

  validates :password, length: {minimum: 6},
    confirmation: {if: Proc.new {password_confirmation.present?}}
  validates :password_confirmation, presence: true
  validate :params_are_valid_for_user

  def initialize(options = {})
    self.first_name = options[:first_name]
    self.email = options[:email]
    self.password = options[:password]
    self.password_confirmation = options[:password_confirmation]
    self.virtual_currency_name = options[:virtual_currency_name]
    self.provider = options[:provider]
    self.ip = options[:ip]
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
      first_name: first_name,
      email: email,
      password_hash: password.hashed_value,
      salt: password.salt,
      provider: provider,
      ip: ip
    }
  end

  def hashed_password
    Plink::Password.new(unhashed_password: password)
  end
end
