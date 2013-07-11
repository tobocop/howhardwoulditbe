module WalletItemPresenter
  def self.get(wallet_item, options = {})
    wallet_item = wallet_item
    virtual_currency = options[:virtual_currency]
    view_context = options[:view_context]

    presenter_klass = case
                        when wallet_item.open?
                          OpenWalletItemPresenter
                        when wallet_item.locked?
                          LockedWalletItemPresenter
                        else
                          PopulatedWalletItemPresenter
                      end

    presenter_klass.new(wallet_item, virtual_currency: virtual_currency, view_context: view_context)
  end
end