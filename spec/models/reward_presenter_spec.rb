require 'spec_helper'

describe RewardPresenter do
  let(:reward) {
    new_reward(
      logo_url: 'awesome.png',
      name: 'derp',
      description: 'Awesomeness',
      amounts: [
        new_reward_amount
      ]
    )
  }

  let(:virtual_currency_presenter) { VirtualCurrencyPresenter.new(virtual_currency: new_virtual_currency(name: 'Plink points')) }

  describe 'initialize' do
    it 'initializes with a reward object and a virtual_currency_presenter' do
      presenter = RewardPresenter.new(reward: reward, virtual_currency_presenter: virtual_currency_presenter)
      presenter.reward.name.should == reward.name
      presenter.virtual_currency_presenter.currency_name.should == virtual_currency_presenter.currency_name
    end
  end

  describe 'attributes' do
    it 'should return the correct attributes based on how it was initialized' do
      presenter = RewardPresenter.new(reward: reward, virtual_currency_presenter: virtual_currency_presenter)
      presenter.currency_name.should == 'Plink points'
      presenter.logo_url.should == 'awesome.png'
      presenter.name.should == 'derp'
      presenter.description.should == 'Awesomeness'
    end
  end

  describe 'amounts' do
    it 'should return RewardAmountPresenters' do
      presenter = RewardPresenter.new(reward: reward, virtual_currency_presenter: virtual_currency_presenter)
      presenter.amounts.map(&:class).should == [RewardAmountPresenter]
    end
  end
end