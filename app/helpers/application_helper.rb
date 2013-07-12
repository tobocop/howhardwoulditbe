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
end
