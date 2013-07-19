class RewardAmountPresenter

  attr_reader :amount, :virtual_currency_presenter

  def initialize(options = {})
    @reward = options.fetch(:reward)
    @amount = options.fetch(:amount)
    @virtual_currency_presenter = options.fetch(:virtual_currency_presenter)
  end

  delegate :id, :dollar_award_amount, to: :amount
  delegate :currency_name, to: :virtual_currency_presenter

  def currency_award_amount
    virtual_currency_presenter.amount_in_currency(dollar_award_amount)
  end

end