module WalletItemPresenter
  def self.get(wallet_item, options = {})
    wallet_item = wallet_item
    virtual_currency = options[:virtual_currency]

    if wallet_item.open?
      OpenWalletItemPresenter.new(wallet_item, virtual_currency: virtual_currency)
    elsif wallet_item.locked?
      LockedWalletItemPresenter.new(wallet_item)
    else
      PopulatedWalletItemPresenter.new(wallet_item, virtual_currency: virtual_currency)
    end
  end

  class PopulatedWalletItemPresenter
    attr_reader :wallet_item, :virtual_currency

    def initialize(wallet_item, options = {})
      @wallet_item = wallet_item
      @virtual_currency = options[:virtual_currency]
    end

    def partial
      'populated_wallet_item'
    end

    def icon_path
      Plink::RemoteImagePath.url_for(wallet_item.offer.image_url)
    end

    def icon_description
      wallet_item.offer.name
    end

    def max_currency_award_amount
      virtual_currency.amount_in_currency(wallet_item.offer.max_dollar_award_amount)
    end

    def currency_name
      virtual_currency.currency_name
    end

    def offer_id
      wallet_item.offer.id
    end

    def title
    end

    def description
    end
  end

  class LockedWalletItemPresenter
    attr_reader :wallet_item

    def initialize(wallet_item)
      @wallet_item = wallet_item
    end

    def partial
      'locked_wallet_item'
    end

    def icon_path
      "icon_lockedslot.png"
    end

    def icon_description
      "Locked Slot"
    end

    def title
      "This slot is locked."
    end

    def description
      "Complete an offer to unlock this slot."
    end
  end

  class OpenWalletItemPresenter

    attr_reader :wallet_item, :virtual_currency

    def initialize(wallet_item, options = {})
      @wallet_item = wallet_item
      @virtual_currency = options[:virtual_currency]
    end

    def partial
      'open_wallet_item'
    end

    def icon_path
      "icon_emptyslot.png"
    end

    def icon_description
      "Empty Slot"
    end

    def title
      "This slot is empty."
    end

    def description
      "Select an offer to start earning #{virtual_currency.currency_name}."
    end
  end
end