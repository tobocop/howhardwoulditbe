class PasswordResetForm
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validates :new_password, confirmation: true, length: {minimum: 6}
  validates :password_reset, presence: {message: 'link is invalid'}

  attr_reader :new_password, :new_password_confirmation, :token, :password_reset

  def initialize(attributes = {})
    @new_password = attributes[:new_password]
    @new_password_confirmation = attributes[:new_password_confirmation]
    @token = attributes[:token]
    @password_reset = lookup_password_reset_for(@token) if @token.present?
  end

  def lookup_password_reset_for(token)
    PasswordReset.where(token: token).first
  end

  def persisted?
    false
  end

  def save
    if valid?
      user = Plink::UserService.new.find_by_id(password_reset.user_id)
      password = Password.new(unhashed_password: new_password)

      user.update_attributes(password_hash: password.hashed_value, salt: password.salt)
    else
      false
    end
  end
end