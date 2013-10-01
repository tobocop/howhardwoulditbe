class RegistrationLinksController < ApplicationController
  include Tracking

  def show
    @registration_path = Plink::RegistrationLinkService.get_registration_path_by_registration_link_id(params[:id])

    redirect_to root_path unless @registration_path.live?

    session[:tracking_params] = TrackingObject.from_params(build_tracking_params(@registration_path)).to_hash
    store_registration_start_event_id(track_registration_start_event.id)

    @steelhouse_additional_info = steelhouse_additional_info
  end

  def deprecated
    registration_link = Plink::RegistrationLinkMappingService.get_registration_link_by_affiliate_id_and_campaign_hash(params[:aid], params[:c])

    if registration_link
      redirect_to registration_link_path(registration_link, trackable_params)
    else
      redirect_to root_path
    end
  end

private

  def build_tracking_params(registration_path)
    trackable_params.merge(
      aid: registration_path.affiliate_id,
      campaign_id: registration_path.campaign_id,
      landing_page_id: registration_path.landing_page_id
    )
  end

  def trackable_params
    params.except(:controller, :action, :c, :aid)
  end
end
