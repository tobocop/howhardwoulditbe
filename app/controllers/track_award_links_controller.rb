class TrackAwardLinksController < ApplicationController

  def create
    award_link_service = Plink::AwardLinkService.new(params[:award_link_url_value], params[:user_id])
    award_link_service.track_click

    if award_link_service.live?
      award_link_service.award
      redirect_to award_link_service.redirect_url
    else
      flash[:notice] = 'Link expired.'
      redirect_to root_path
    end
  end

end
