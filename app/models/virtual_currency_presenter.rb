class VirtualCurrencyPresenter

  attr_reader :user_balance, :virtual_currency

  def initialize(options = {})
    @virtual_currency = options.fetch(:virtual_currency)
    @user_balance = options.fetch(:user_balance)
  end

  def currency_name
    virtual_currency.name
  end

  def user_balance_currency
    (user_balance * virtual_currency.exchange_rate).to_i.to_s
  end
end