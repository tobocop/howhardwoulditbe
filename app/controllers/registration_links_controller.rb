class RegistrationLinksController < ApplicationController
  include Tracking

  def show
    @registration_flow = Plink::RegistrationLinkService.get_registration_flow_by_registration_link_id(params[:id])

    redirect_to root_path unless @registration_flow.live?
    redirect_to cf_mobile_registration(@registration_flow) if is_mobile?(@registration_flow)

    session[:registration_link_id] = params[:id]
    session[:share_page_id] = @registration_flow.share_flow? ? @registration_flow.share_page_id : nil

    session[:tracking_params] = TrackingObject.from_params(build_tracking_params(@registration_flow)).to_hash
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

  def cf_mobile_registration(registration_flow)
    new_query_string = "&aid=#{registration_flow.affiliate_id}" + "&campaignID=#{registration_flow.campaign_id}" + "&" + request.query_string

    Plink::Config.instance.mobile_registration_url + new_query_string
  end

  def build_tracking_params(registration_flow)
    trackable_params.merge(
      aid: registration_flow.affiliate_id,
      campaign_id: registration_flow.campaign_id,
      landing_page_id: registration_flow.landing_page_id
    )
  end

  def trackable_params
    params.except(:controller, :action, :c, :aid)
  end

  def is_mobile?(registration_flow)
    request.user_agent =~ /Mobile|webOS/i && registration_flow.mobile_detection_on?
  end
end
