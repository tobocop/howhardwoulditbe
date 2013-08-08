module RewardsHelper

  def display_as_available?(user_has_account, dollar_amount)
    user_has_account && current_user.can_redeem? &&
      dollar_amount <= Plink::RewardAmount::MAXIMUM_REDEMPTION_VALUE &&
      dollar_amount <= current_user.current_balance
  end

end
