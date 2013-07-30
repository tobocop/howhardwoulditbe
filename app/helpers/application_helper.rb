module ApplicationHelper
  def class_for_nav_tab(current_tab, tab)
    current_tab == tab ? 'selected' : ''
  end

  def plink_currency_format(amount)
    amount = number_to_currency(amount)

    if amount.match /\.00/
      amount[0..amount.index('.')-1]
    else
      amount
    end
  end

  def redemption_confirmation_text(amount, reward_name)
    "You're about to redeem #{amount.currency_award_amount} #{amount.currency_name} "\
    "for a #{plink_currency_format(amount.dollar_award_amount)} #{reward_name} Gift Card."
  end

  def contact_us_message
    "Need help? Please #{link_to 'contact us', contact_path, class: 'text-link'}.".html_safe
  end
end
