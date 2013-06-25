class ReferralsController < ApplicationController

  def create
    session[:referrer_id] = params[:user_id].to_i
    session[:affiliate_id] = params[:affiliate_id].to_i
    redirect_to root_path
  end
end