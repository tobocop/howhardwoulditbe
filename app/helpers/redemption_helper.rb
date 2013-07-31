module RedemptionHelper
  def redemption_message(points_from_next_redemption, currency_name)
    if points_from_next_redemption > 0
      "You're <strong>#{sprintf('%g', points_from_next_redemption)} #{currency_name}</strong> from your next reward."
    else
      link_to "You have enough Plink Points to redeem for a Gift card.", rewards_path, class: 'redeem-link'
    end
  end
end
