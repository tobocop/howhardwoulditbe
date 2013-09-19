class ContestReferralsController < ApplicationController

  def new
    session[:referrer_id] = params[:user_id].to_i
    session[:affiliate_id] = params[:affiliate_id].to_i
    session[:contest_source] = params[:source]

    session[:tracking_params] = TrackingObject.new({
      affiliate_id: session[:affiliate_id],
      sub_id: session[:contest_source],
      sub_id_three: 'contest_id_' + params[:contest_id]
    }).to_hash

    redirect_to contests_path
  end

end
