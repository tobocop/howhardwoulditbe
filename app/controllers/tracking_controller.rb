class TrackingController < ApplicationController
  include TrackingExtensions

  def new
    set_session_tracking_params(new_tracking_object_from_params(params))
    redirect_to root_path
  end
end
