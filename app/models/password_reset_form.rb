class PasswordResetForm

  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_reader :email, :plink_user_service

  def initialize(attributes = {}, plink_user_service = Plink::UserService.new)
    @email = attributes[:email]
    @plink_user_service = plink_user_service
  end

  def persisted?
    false
  end

  validate do
    unless plink_user_service.find_by_email(email)
      errors[:base] << 'Sorry this email is not registered with Plink.'
    end
  end

  def save
    valid? ? true : false
  end
end
