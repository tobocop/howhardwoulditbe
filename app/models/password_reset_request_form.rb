class PasswordResetRequestForm

  include ActiveModel::Validations
  include ActiveModel::Conversion

  validates_presence_of :user
  validates :email, format: {with: Plink::UserRecord::VALID_EMAIL_REGEXP, allow_blank: true}

  attr_reader :email, :plink_user_service, :user

  def initialize(attributes = {}, plink_user_service = Plink::UserService.new)
    @email = attributes[:email]
    @plink_user_service = plink_user_service
    @user = plink_user_service.find_by_email(email)
  end

  def persisted?
    false
  end

  def save
    if valid?
      password_reset = PasswordReset.build(user_id: user.id)
      PasswordResetMailer.instructions(email, @user.first_name, password_reset.token).deliver
      true
    else
      false
    end
  end
end
