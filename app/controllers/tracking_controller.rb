class TrackingController < ApplicationController
  include TrackingExtensions

  before_filter :require_authentication, only: [:hero_promotion_click]

  def new
    set_session_tracking_params(new_tracking_object_from_params(params))
    redirect_to root_path
  end

  def hero_promotion_click
    click_params = {user_id: current_user.id, hero_promotion_id: params[:hero_promotion_id]}
    Plink::HeroPromotionClickRecord.create(click_params)

    render nothing: true
  end
end
