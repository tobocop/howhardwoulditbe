class OffersController < ApplicationController

  def index
    @offers = plink_offer_service.get_live_offers(current_virtual_currency.id)
    @hero_promotions = plink_hero_promotion_service.by_display_order
  end

  private

  def plink_hero_promotion_service
    Plink::HeroPromotionRecord
  end

  def plink_offer_service
    @offer_service ||= Plink::OfferService.new
  end
end
