class HomeController < ApplicationController

  def index
    redirect_to wallet_path if user_logged_in?
  end

  def plink_video
    render layout: false
  end
end
