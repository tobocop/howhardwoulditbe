class DashboardController < ApplicationController
  before_filter :require_authentication

  def show
    @current_tab = 'dashboard'
    @hero_promotions = HeroPromotion.order(:display_order).all
  end
end
