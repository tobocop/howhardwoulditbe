class OffersController < ApplicationController

  def index
    @offers = present_offers(plink_offer_service.get_live_offers(current_virtual_currency.id), false)
    @hero_promotions = plink_hero_promotion_service.active_promotions
  end

  private

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
    @offer_service ||= Plink::OfferService.new
  end
end
