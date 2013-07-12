module WalletItemPresenter
  class PopulatedWalletItemJsPresenter < BaseWalletItemJsPresenter

    def max_currency_award_amount
      '{{max_currency_award_amount}}'
    end

    def currency_name
      '{{currency_name}}'
    end

    def offer_id
      '{{offer_id}}'
    end

    def wallet_offer_url
      '{{wallet_offer_url}}'
    end
  end
end