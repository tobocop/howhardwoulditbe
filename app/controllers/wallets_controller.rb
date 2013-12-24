class WalletsController < ApplicationController
  include TrackingExtensions
  include WalletExtensions
  include AutoLoginExtensions

  before_filter :require_authentication, only: :show

  def show
    @current_tab = 'wallet'
    @user_has_account = plink_intuit_account_service.user_has_account?(current_user.id)
    @hero_promotions = present_hero_promotions(plink_hero_promotion_service.active_for_user(current_user.id, @user_has_account))
    @wallet_items = presented_wallet_items
    @card_link_url = plink_card_link_url_generator.create_url(get_session_tracking_params)
    @offers = present_offers(plink_offer_service.get_available_offers_for(wallet_id, current_virtual_currency.id), @user_has_account)
    @all_offers = present_offers(plink_offer_service.get_live_offers(current_virtual_currency.id), @user_has_account)
  end

  def login_from_email
    auto_login_user(params[:user_token], wallet_path)
  end

private

  def present_hero_promotions(hero_promotions)
    hero_promotions.map do |hero_promotion|
      HeroPromotionPresenter.new(hero_promotion, current_user.id)
    end
  end

  def present_offers(offers, user_has_account)
    offers.map do |offer|
      OfferItemPresenter.new(
        offer,
        virtual_currency: current_virtual_currency,
        view_context: self.view_context,
        linked: user_has_account,
        signed_in: current_user.logged_in?
      )
    end
  end

  def plink_hero_promotion_service
    Plink::HeroPromotionService.new
  end

  def plink_offer_service
    Plink::OfferService.new
  end
end
