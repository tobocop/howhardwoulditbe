class PasswordResetForm
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validates :new_password, confirmation: true, length: {minimum: 6}
  validate :password_reset_is_valid

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
      user = plink_user_service.find_by_id(password_reset.user_id)
      password = Plink::Password.new(unhashed_password: new_password)
      plink_user_service.update(user.id, {password_hash: password.hashed_value, salt: password.salt})
    else
      false
    end
  end

  private

  def plink_user_service
    @plink_user_service ||= Plink::UserService.new
  end

  def password_reset_is_valid
    if password_reset.nil?
      errors.add(:base, 'Sorry, this link is invalid.')
    elsif password_reset.created_at < 24.hours.ago
      errors.add(:base, 'Sorry, the reset password link has expired.  Please visit the login screen and request a new reset password link.')
    end
  end
end
