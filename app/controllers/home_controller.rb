class HomeController < ApplicationController

  include Tracking

  def index
    redirect_to wallet_path if user_logged_in?
    @steelhouse_additional_info = steelhouse_additional_info
  end

  def plink_video
    render layout: false
  end
end
