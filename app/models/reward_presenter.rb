class RewardPresenter

  attr_reader :reward, :virtual_currency_presenter

  def initialize(attributes = {})
    @reward = attributes.fetch(:reward)
    @virtual_currency_presenter = attributes.fetch(:virtual_currency_presenter)
  end

  delegate :currency_name, to: :virtual_currency_presenter
  delegate :logo_url, :name, :description, to: :reward

  def amounts
    reward.amounts.map do |amount|
      presenter_attrs = {
        reward: reward,
        amount: amount,
        virtual_currency_presenter: virtual_currency_presenter
      }

      RewardAmountPresenter.new(presenter_attrs)
    end
  end

end