class TrackingController < ApplicationController

  def new
    session[:tracking_params] = tracking_object(params.except(:controller, :action)).to_hash
    redirect_to root_path
  end

  private

  def tracking_object(options)
    TrackingObject.from_params(options)
  end
end