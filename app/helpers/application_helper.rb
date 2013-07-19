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

  def redemption_confirmation_text(dollar_award_amount, reward_name)
    "You're about to redeem #{current_virtual_currency.amount_in_currency(dollar_award_amount)} "\
    "#{current_virtual_currency.currency_name} for a #{plink_currency_format(dollar_award_amount)} "\
    "#{reward_name} Gift Card."
  end

end
