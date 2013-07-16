class DashboardController < ApplicationController
  before_filter :require_authentication

  def show
    @current_tab = 'dashboard'
    @hero_promotions = plink_hero_promotion_service.active_promotions
  end

  private

  def plink_hero_promotion_service
    Plink::HeroPromotionService.new
  end

end
