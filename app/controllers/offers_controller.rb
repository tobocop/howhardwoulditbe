class OffersController < ApplicationController

  layout 'logged_out'

  def index
    @offers = plink_offer_service.get_live_offers(current_virtual_currency.id)
    @hero_promotions = HeroPromotion.by_display_order
  end

  private

  def plink_offer_service
    @offer_service ||= Plink::OfferService.new
  end
end
