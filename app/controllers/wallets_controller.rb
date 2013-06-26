class WalletsController < ApplicationController
  before_filter :require_authentication
  layout 'logged_in'

  def show
    @current_tab = 'wallet'
    @hero_promotions = HeroPromotion.by_display_order
  end
end