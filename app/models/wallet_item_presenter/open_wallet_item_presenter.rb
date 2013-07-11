module WalletItemPresenter
  class OpenWalletItemPresenter < BaseWalletItemPresenter

    attr_reader :wallet_item, :virtual_currency, :view_context

    def initialize(wallet_item, options = {})
      @wallet_item = wallet_item
      @virtual_currency = options.fetch(:virtual_currency)
      @view_context = options.fetch(:view_context)
    end

    def partial
      template_name
    end

    def template_name
      'open_wallet_item'
    end

    def icon_url
      view_context.image_path('icon_emptyslot.png')
    end

    def icon_description
      'Empty Slot'
    end

    def title
      'This slot is empty.'
    end

    def description
      "Select an offer to start earning #{virtual_currency.currency_name}."
    end
  end
end