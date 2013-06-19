class VirtualCurrencyPresenter

  attr_accessor :user_balance, :virtual_currency

  def initialize(options = {})
    self.virtual_currency = options.fetch(:virtual_currency)
    self.user_balance = options.fetch(:user_balance).to_i.to_s
  end

  def currency_name
    virtual_currency.name
  end
end