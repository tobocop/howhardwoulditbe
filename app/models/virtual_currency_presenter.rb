class VirtualCurrencyPresenter

  attr_reader :user_balance, :virtual_currency, :subdomain

  def initialize(options = {})
    @virtual_currency = options.fetch(:virtual_currency)
    @user_balance = options.fetch(:user_balance, 0)
  end

  def currency_name
    virtual_currency.name
  end

  def subdomain
    virtual_currency.subdomain
  end

  def user_balance_currency
    (user_balance * virtual_currency.exchange_rate).to_i.to_s
  end
end