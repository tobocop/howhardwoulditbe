module Plink
  class StringSubstituter

    extend ActionView::Helpers::NumberHelper

    def self.gsub(original_string, tier, virtual_currency)
      new_string = original_string.dup
      new_string.gsub!('$minimumPurchaseAmount$', number_to_currency(tier.minimum_purchase_amount.to_s, unit: ''))
      new_string.gsub!('$vc_currencyName$', virtual_currency.currency_name)
      new_string.gsub!('$vc_dollarAmount$', vc_dollar_amount(tier, virtual_currency))
      new_string
    end

    private

    def self.vc_dollar_amount(tier, virtual_currency)
      "#{(virtual_currency.exchange_rate * tier.dollar_award_amount).to_i.to_s} #{virtual_currency.currency_name}"
    end
  end
end
