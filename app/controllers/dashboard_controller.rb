class DashboardController < ApplicationController
  before_filter :require_authentication

  def show
    @current_tab = 'dashboard'
    @hero_promotions = plink_hero_promotion_service.by_display_order
  end

  private

  def plink_hero_promotion_service
    Plink::HeroPromotionRecord
  end

end
