class VirtualCurrencyPresenter

  attr_reader :user_balance, :virtual_currency, :id

  def initialize(options = {})
    @virtual_currency = options.fetch(:virtual_currency)
  end

  def id
    virtual_currency.id
  end

  def currency_name
    virtual_currency.name
  end

  def exchange_rate
    virtual_currency.exchange_rate
  end

  def amount_in_currency(amount)
    return 0 if amount.nil?
    (amount* virtual_currency.exchange_rate).to_i.to_s
  end
end