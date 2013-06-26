class WalletsController < ApplicationController
  before_filter :require_authentication
  layout 'logged_in'

  def show
    @current_tab = 'wallet'
    @hero_promotions = HeroPromotion.order(:display_order).all
  end
end