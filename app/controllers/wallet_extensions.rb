module WalletExtensions
  def wallet_items
    plink_wallet_item_service.get_for_wallet_id(wallet_id)
  end

  def wallet_id
    current_user.wallet.id
  end

  def plink_wallet_item_service
    Plink::WalletItemService.new
  end

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end

  def presented_wallet_items
    wallet_items.map do |item|
      WalletItemPresenter.get(item, virtual_currency: current_virtual_currency, view_context: view_context)
    end
  end
end