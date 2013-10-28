class CurrencyActivityPresenter

  def self.build_currency_activity(debits_credit)
    options = {}

    if debits_credit.is_reward?
      options = {
        amount_css_class: 'chart',
        icon_path: 'history/icon_redeem.png',
        icon_description: 'Redemption'
      }
    elsif debits_credit.is_qualified?
      options = {
        amount_css_class: 'cyan',
        icon_path: 'history/icon_purchase.png',
        icon_description: 'Purchase'
      }
    else
      options = {
        amount_css_class: 'cyan',
        icon_path: 'history/icon_bonus.png',
        icon_description: 'Bonus'
      }
    end

    new(debits_credit, options)
  end

  attr_reader :debits_credit, :amount_css_class, :icon_path, :icon_description

  def initialize(debits_credit, options)
    @debits_credit = debits_credit

    @amount_css_class = options[:amount_css_class]
    @icon_path = options[:icon_path]
    @icon_description = options[:icon_description]
  end

  delegate :dollar_award_amount, :currency_award_amount, :display_currency_name,
    :award_display_name, to: :debits_credit

  def display_date
    debits_credit.awarded_on.to_s(:month_day)
  end

end
