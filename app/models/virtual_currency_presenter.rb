class VirtualCurrencyPresenter

  attr_reader :user_balance, :virtual_currency, :id

  def initialize(options = {})
    @virtual_currency = options.fetch(:virtual_currency)
  end

  def currency_name
    virtual_currency.name
  end

  def id
    virtual_currency.id
  end

  def amount_in_currency(amount)
    (amount* virtual_currency.exchange_rate).to_i.to_s
  end
end