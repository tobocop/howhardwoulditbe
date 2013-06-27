class WalletsController < ApplicationController
  before_filter :require_authentication
  layout 'logged_in'

  def show
    @current_tab = 'wallet'
    @hero_promotions = HeroPromotion.by_display_order
    @offers = plink_offer_service.get_live_offers(current_virtual_currency.id)
  end

  private

  def plink_offer_service
    Plink::OfferService.new
  end
end