class ReferralsController < ApplicationController

  def create
    session[:referrer_id] = params[:user_id].to_i
    session[:affiliate_id] = params[:affiliate_id].to_i

    session[:tracking_params] = referral_tracking_params

    if is_mobile?
      redirect_to mobile_reg_path(session)
    else
      redirect_to root_path
    end
  end

private

  def referral_tracking_params
    TrackingObject.new({
      affiliate_id: params[:affiliate_id]
    }).to_hash
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
