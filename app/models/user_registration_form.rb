class UserRegistrationForm
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_accessor :email, :first_name, :ip, :password, :password_confirmation, :provider,
    :user, :user_agent, :user_creation_service, :virtual_currency_name

  validates :password, length: {minimum: 6},
    confirmation: {if: Proc.new {password_confirmation.present?}}
  validates :password_confirmation, presence: true
  validate :params_are_valid_for_user

  def initialize(options = {})
    self.email = options[:email]
    self.first_name = options[:first_name]
    self.ip = options[:ip]
    self.password = options[:password]
    self.password_confirmation = options[:password_confirmation]
    self.provider = options[:provider]
    self.user_agent = options[:user_agent]
    self.virtual_currency_name = options[:virtual_currency_name]
  end

  def save
    return unless valid?
    self.user = user_creation_service.create_user

    AfterUserRegistration.delay(run_at: 20.minutes.from_now).send_complete_your_registration_email(user.id)

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
      email: email,
      first_name: first_name,
      ip: ip,
      password_hash: password.hashed_value,
      provider: provider,
      salt: password.salt,
      user_agent: user_agent
    }
  end

  def hashed_password
    Plink::Password.new(unhashed_password: password)
  end
end
