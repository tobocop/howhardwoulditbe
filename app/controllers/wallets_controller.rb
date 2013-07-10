class WalletsController < ApplicationController
  before_filter :require_authentication

  def show
    @current_tab = 'wallet'
    @hero_promotions = HeroPromotion.by_display_order
    @offers = plink_offer_service.get_live_offers(current_virtual_currency.id)
    @user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    @wallet_items = wrap_wallet_items(wallet_items)
  end

  private

  def wrap_wallet_items(items)
    items.map { |item| WalletItemPresenter.get(item, virtual_currency: current_virtual_currency) }
  end

  def wallet_items
    plink_wallet_item_service.get_for_wallet_id(current_user.wallet.id)
  end

  def plink_wallet_item_service
    Plink::WalletItemService.new
  end

  def plink_offer_service
    Plink::OfferService.new
  end

  def plink_intuit_account_service
    Plink::IntuitAccountService.new
  end
end