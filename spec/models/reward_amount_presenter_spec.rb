require 'spec_helper'

describe RewardAmountPresenter do

  let(:reward) { create_reward(name: 'Wally Mart') }
  let(:amount) { create_reward_amount(dollar_award_amount: 1.23, reward_id: 123) }
  let(:virtual_currency_presenter) { VirtualCurrencyPresenter.new(virtual_currency: new_virtual_currency(name: 'Plink points')) }

  describe 'initialize' do
    it 'can be initialized with a Plink::RewardAmount, VirtualCurrencyPresenter, Plink::RewardRecord' do
      presenter = RewardAmountPresenter.new(amount: amount, virtual_currency_presenter: virtual_currency_presenter, reward: reward)
      presenter.dollar_award_amount.should == 1.23
      presenter.currency_award_amount.should == '123'
      presenter.currency_name.should == 'Plink points'
      presenter.id.should == amount.id
    end
  end
end