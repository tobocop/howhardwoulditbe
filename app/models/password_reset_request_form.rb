class PasswordResetRequestForm

  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_reader :email, :plink_user_service, :user

  def initialize(attributes = {}, plink_user_service = Plink::UserService.new)
    @email = attributes[:email]
    @plink_user_service = plink_user_service
  end

  def persisted?
    false
  end

  validate do
    unless user
      errors[:base] << 'Sorry this email is not registered with Plink.'
      errors[:base] << "An email with instructions to reset your password has been sent to the email address provided.  If you don't receive an email within the hour, please contact our member support."
    end
  end

  def save
    @user = plink_user_service.find_by_email(email)

    if valid?
      password_reset = PasswordReset.build(user_id: user.id)
      PasswordResetMailer.instructions(email, @user.first_name, password_reset.token).deliver
      true
    else
      false
    end
  end
end
