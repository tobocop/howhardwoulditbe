class TrackingController < ApplicationController

  def new
    session[:tracking_params] = tracking_object(build_tracking_params).to_hash
    redirect_to root_path
  end

  private

  def build_tracking_params
    trackable_params = params.except(:controller, :action)
    trackable_params.merge(campaign_id: campaign_id)
  end

  def campaign_id
    params['c'] ? Plink::EventService.new.get_campaign_id(params['c']) : nil
  end

  def tracking_object(options)
    TrackingObject.from_params(options)
  end
end
