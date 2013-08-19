module RedemptionHelper
  def redemption_message(point_balance, currency_name)
    if point_balance < 1000
      "You're <strong>#{sprintf('%g', 1000 - point_balance)} #{currency_name}</strong> from your next reward."
    else
      link_to "You have enough #{currency_name} to redeem for a Gift card.", rewards_path, class: 'redeem-link'
    end
  end
end
