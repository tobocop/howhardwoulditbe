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
    end
  end

  def save
    @user = plink_user_service.find_by_email(email)

    if valid?
      PasswordResetMailer.instructions(email, @user.first_name).deliver
      true
    else
      false
    end
  end
end
