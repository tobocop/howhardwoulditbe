require 'spec_helper'

describe Plink::StringSubstituter do
  let(:original_string) { "Minimum: $minimumPurchaseAmount$ Currency Name: $vc_currencyName$ Award amount: $vc_dollarAmount$" }

  let(:tier) { new_tier(minimum_purchase_amount: 199.50, dollar_award_amount: 5) }
  let(:virtual_currency) { mock('VirtualCurrency', currency_name: 'Plink Points', exchange_rate: 100) }

  describe '.gsub' do
    it 'replaces $minimumPurchaseAmount$ with the given tiers minimum purchase amount' do
      Plink::StringSubstituter.gsub(original_string, tier, virtual_currency).should == 'Minimum: 199.50 Currency Name: Plink Points Award amount: 500 Plink Points'
    end
  end
end
