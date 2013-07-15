class WalletsController < ApplicationController
  include WalletExtensions

  before_filter :require_authentication

  def show
    @current_tab = 'wallet'
    @hero_promotions = plink_hero_promotion_service.by_display_order
    @offers = plink_offer_service.get_available_offers_for(wallet_id, current_virtual_currency.id)
    @user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    @wallet_items = presented_wallet_items
  end

  private

  def plink_hero_promotion_service
    Plink::HeroPromotionRecord
  end

  def plink_offer_service
    Plink::OfferService.new
  end
end