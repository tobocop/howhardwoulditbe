class DashboardController < ApplicationController
  before_filter :require_authentication

  def show
    @hero_promotions = HeroPromotion.order(:display_order).all
  end
end