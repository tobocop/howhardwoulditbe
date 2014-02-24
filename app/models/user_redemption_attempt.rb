class UserRedemptionAttempt
  include ActiveModel::Validations
  include ActiveModel::Conversion

  validate :user_has_account
  validate :user_is_not_fishy

  attr_reader :fishy, :needs_account, :user_id

  def initialize(user_id)
    @user_id = user_id
  end

  def error_messages
    errors.full_messages.join(' ')
  end

private

  def user_has_account
    unless plink_intuit_account_service.user_has_account?(user_id)
      errors.add(:needs_account, 'You must have a linked card to redeem an award.')
    end
  end

  def user_is_not_fishy
    if Plink::FishyService.user_fishy?(user_id)
      errors.add(:fishy, 'We could not process your reward, please contact customer support.')
    end
  end

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end
end
