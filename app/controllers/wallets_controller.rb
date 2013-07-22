class WalletsController < ApplicationController
  include WalletExtensions

  before_filter :require_authentication

  def show
    @current_tab = 'wallet'
    @hero_promotions = plink_hero_promotion_service.active_promotions
    @offers = plink_offer_service.get_available_offers_for(wallet_id, current_virtual_currency.id)
    @user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    @wallet_items = presented_wallet_items
    @card_link_url = plink_card_link_url_generator.create_url({})
  end

  private

  def plink_hero_promotion_service
    Plink::HeroPromotionService.new
  end

  def plink_offer_service
    Plink::OfferService.new
  end

  def plink_card_link_url_generator
    Plink::CardLinkUrlGenerator.new(Plink::Config.instance)
  end
end