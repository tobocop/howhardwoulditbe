class ReferralsController < ApplicationController
  include TrackingExtensions

  def create
    set_session_tracking_params(new_tracking_object_from_params(trackable_params))

    if is_mobile?
      redirect_to mobile_reg_path(get_session_tracking_params)
    else
      redirect_to root_path
    end
  end

private

  def trackable_params
    params.merge(aid: params[:affiliate_id])
  end

  def mobile_reg_path(url_params)
    Plink::Config.instance.mobile_registration_url +
      '&refer=' + url_params[:referrer_id].to_s +
      '&affiliate_id=' + url_params[:affiliate_id].to_s
  end

  def is_mobile?
    request.user_agent =~ /Mobile|webOS/
  end
end
